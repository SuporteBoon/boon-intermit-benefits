'use strict';

import { pool } from '../../../infra/database/postgres.js';

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body || '{}');

    const requiredFields = [
      'razao_social_empresa',
      'cnpj_empresa',
      'nome_evento',
      'data_inicio_contrato',
      'data_fim_contrato',
      'cpf_segurado',
      'nome_segurado'
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

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // 1. Estipulante (Empresa)
      let estipulanteId;
      const resEstipulante = await client.query(
        'SELECT id FROM "intermit-benefits".tb_estipulante WHERE cpf_cnpj = $1',
        [body.cnpj_empresa]
      );
      if (resEstipulante.rows.length > 0) {
        estipulanteId = resEstipulante.rows[0].id;
      } else {
        const insertEstipulante = await client.query(
          `INSERT INTO "intermit-benefits".tb_estipulante (estipulante, razao_social, cpf_cnpj, ativo, data_cadastro)
           VALUES ($1, $2, $3, $4, $5) RETURNING id`,
          [body.razao_social_empresa, body.razao_social_empresa, body.cnpj_empresa, true, new Date()]
        );
        estipulanteId = insertEstipulante.rows[0].id;
      }

      // 2. Contrato (Evento)
      // Código único de apólice derivado
      const cleanCnpj = body.cnpj_empresa.replace(/\D/g, '');
      const cleanEventName = body.nome_evento.toLowerCase().replace(/[^a-z0-9]/g, '_');
      const codigoApolice = `${cleanCnpj}_${cleanEventName}`;

      let contratoId;
      const resContrato = await client.query(
        'SELECT id FROM "intermit-benefits".tb_contrato WHERE estipulante_id = $1 AND codigo_contrato_apolice = $2',
        [estipulanteId, codigoApolice]
      );
      if (resContrato.rows.length > 0) {
        contratoId = resContrato.rows[0].id;
      } else {
        const insertContrato = await client.query(
          `INSERT INTO "intermit-benefits".tb_contrato (
            estipulante_id, produto, codigo_contrato_apolice, data_vigencia_inicio, data_vigencia_final, ativo, data_cadastro
           ) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
          [
            estipulanteId,
            body.nome_evento,
            codigoApolice,
            body.data_inicio_contrato,
            body.data_fim_contrato,
            true,
            new Date()
          ]
        );
        contratoId = insertContrato.rows[0].id;
      }

      // 3. Beneficiario (Segurado)
      let beneficiarioId;
      const resBeneficiario = await client.query(
        'SELECT id FROM "intermit-benefits".tb_beneficiario WHERE cpf = $1',
        [body.cpf_segurado]
      );
      if (resBeneficiario.rows.length > 0) {
        beneficiarioId = resBeneficiario.rows[0].id;
        await client.query(
          `UPDATE "intermit-benefits".tb_beneficiario
           SET nome = $1, telefone = $2, status = $3, data_atualizacao = $4
           WHERE id = $5`,
          [body.nome_segurado, body.celular_segurado, 'AGUARDANDO_CHECKIN', new Date(), beneficiarioId]
        );
      } else {
        const insertBeneficiario = await client.query(
          `INSERT INTO "intermit-benefits".tb_beneficiario (nome, cpf, telefone, status, data_cadastro)
           VALUES ($1, $2, $3, $4, $5) RETURNING id`,
          [body.nome_segurado, body.cpf_segurado, body.celular_segurado, 'AGUARDANDO_CHECKIN', new Date()]
        );
        beneficiarioId = insertBeneficiario.rows[0].id;
      }

      // 4. Cobertura Beneficiario (Adesão)
      let coberturaId;
      const resCobertura = await client.query(
        'SELECT id FROM "intermit-benefits".tb_cobertura_beneficiario WHERE beneficiario_id = $1 AND contrato_origem_id = $2',
        [beneficiarioId, contratoId]
      );
      if (resCobertura.rows.length > 0) {
        coberturaId = resCobertura.rows[0].id;
        await client.query(
          `UPDATE "intermit-benefits".tb_cobertura_beneficiario
           SET data_inicio_cobertura = $1, data_fim_cobertura = $2, status = $3, data_atualizacao = $4
           WHERE id = $5`,
          [body.data_inicio_contrato, body.data_fim_contrato, 'AGUARDANDO_CHECKIN', new Date(), coberturaId]
        );
      } else {
        const insertCobertura = await client.query(
          `INSERT INTO "intermit-benefits".tb_cobertura_beneficiario (
            beneficiario_id, contrato_origem_id, data_inicio_cobertura, data_fim_cobertura, status, data_criacao
           ) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
          [
            beneficiarioId,
            contratoId,
            body.data_inicio_contrato,
            body.data_fim_contrato,
            'AGUARDANDO_CHECKIN',
            new Date()
          ]
        );
        coberturaId = insertCobertura.rows[0].id;
      }

      await client.query('COMMIT');

      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: 'Adesão recebida e validada com sucesso',
          status: 'AGUARDANDO_CHECKIN'
        })
      };

    } catch (dbError) {
      await client.query('ROLLBACK');
      throw dbError;
    } finally {
      client.release();
    }

  } catch (error) {
    console.error('Erro ao processar adesão:', error.message);
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
