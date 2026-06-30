'use strict';

import { pool } from '../../../infra/database/postgres.js';

export const handler = async (event) => {
  try {
    const body = event

    const requiredFields = [
      'cnpj_empresa',
      'cpf_segurado',
      'numero_contrato'
    ];

    const missingFields = requiredFields.filter(field => !body[field]);

    if (missingFields.length > 0) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          error: 'Bad Request',
          message: `Campos obrigatórios ausentes: ${missingFields.join(', ')}`
        })
      };
    }

    // Suportar tanto "data_rescisao" quanto " data_rescisao " com espaços
    const dataRescisaoRaw = body.data_rescisao || body[' data_rescisao '] || body['data_rescisao '] || body[' data_rescisao'];
    const dataRescisao = dataRescisaoRaw ? new Date(dataRescisaoRaw.trim()) : new Date();

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // 1. Buscar Estipulante
      const resEstipulante = await client.query(
        'SELECT id FROM "intermit-benefits".tb_estipulante WHERE cpf_cnpj = $1',
        [body.cnpj_empresa]
      );
      if (resEstipulante.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 404,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ error: 'Not Found', message: 'Empresa (Estipulante) não encontrada.' })
        };
      }
      const estipulanteId = resEstipulante.rows[0].id;

      // 2. Buscar Contrato
      const resContrato = await client.query(
        'SELECT id FROM "intermit-benefits".tb_contrato WHERE estipulante_id = $1 AND codigo_contrato_apolice = $2',
        [estipulanteId, body.numero_contrato]
      );
      if (resContrato.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 404,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ error: 'Not Found', message: 'Contrato não encontrado para esta empresa.' })
        };
      }
      const contratoId = resContrato.rows[0].id;

      // 3. Buscar Beneficiario
      const resBeneficiario = await client.query(
        'SELECT id FROM "intermit-benefits".tb_beneficiario WHERE cpf = $1',
        [body.cpf_segurado]
      );
      if (resBeneficiario.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 404,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ error: 'Not Found', message: 'Beneficiário (Segurado) não encontrado.' })
        };
      }
      const beneficiarioId = resBeneficiario.rows[0].id;

      // 4. Buscar Cobertura
      const resCobertura = await client.query(
        'SELECT id FROM "intermit-benefits".tb_cobertura_beneficiario WHERE beneficiario_id = $1 AND contrato_origem_id = $2',
        [beneficiarioId, contratoId]
      );
      if (resCobertura.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 404,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ error: 'Not Found', message: 'Cobertura do beneficiário não encontrada para este contrato.' })
        };
      }
      const coberturaId = resCobertura.rows[0].id;

      // 5. Atualizar Cobertura para CANCELADO e data de fim de cobertura
      await client.query(
        `UPDATE "intermit-benefits".tb_cobertura_beneficiario
         SET status = $1, data_fim_cobertura = $2, data_atualizacao = $3
         WHERE id = $4`,
        ['CANCELADO', dataRescisao, new Date(), coberturaId]
      );

      // 6. Atualizar Beneficiario para CANCELADO
      await client.query(
        `UPDATE "intermit-benefits".tb_beneficiario
         SET status = $1, data_atualizacao = $2
         WHERE id = $3`,
        ['CANCELADO', new Date(), beneficiarioId]
      );

      await client.query('COMMIT');

      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: 'Contrato rescindido com sucesso',
          status: 'CANCELADO'
        })
      };

    } catch (dbError) {
      await client.query('ROLLBACK');
      throw dbError;
    } finally {
      client.release();
    }

  } catch (error) {
    console.error('Erro ao processar rescisão:', error.message);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        error: 'Internal Server Error',
        message: error.message
      })
    };
  }
};
