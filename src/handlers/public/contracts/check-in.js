'use strict';

import { pool } from '../../../infra/database/postgres.js';

export const handler = async (event) => {
  try {
    const body = event

    const requiredFields = [
      'cnpj_empresa',
      'cpf_segurado',
      'numero_contrato',
      'data_checkin'
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

      // 1. Verificar se o contrato existe (validando também a empresa e o nome do evento associado)
      const resContrato = await client.query(
        `SELECT c.id FROM "intermit-benefits".tb_contrato c
         JOIN "intermit-benefits".tb_estipulante e ON c.estipulante_id = e.id
         WHERE c.codigo_contrato_apolice = $1 AND e.cpf_cnpj = $2`,
        [body.numero_contrato, body.cnpj_empresa]
      );
      if (resContrato.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 400,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            error: 'Bad Request',
            message: 'Entidade contrato não encontrada no database.'
          })
        };
      }
      const contratoId = resContrato.rows[0].id;

      // 2. Verificar se o beneficiário existe
      const resBeneficiario = await client.query(
        'SELECT id FROM "intermit-benefits".tb_beneficiario WHERE cpf = $1',
        [body.cpf_segurado]
      );
      if (resBeneficiario.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 400,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            error: 'Bad Request',
            message: 'Entidade beneficiário não encontrada no database.'
          })
        };
      }
      const beneficiarioId = resBeneficiario.rows[0].id;

      // 3. Verificar se a cobertura existe
      const resCobertura = await client.query(
        'SELECT id FROM "intermit-benefits".tb_cobertura_beneficiario WHERE beneficiario_id = $1 AND contrato_origem_id = $2',
        [beneficiarioId, contratoId]
      );
      if (resCobertura.rows.length === 0) {
        await client.query('ROLLBACK');
        return {
          statusCode: 400,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            error: 'Bad Request',
            message: 'Entidade cobertura não encontrada no database.'
          })
        };
      }
      const coberturaId = resCobertura.rows[0].id;

      // 4. Alterar status do beneficiário para ATIVO
      await client.query(
        `UPDATE "intermit-benefits".tb_beneficiario
         SET status = $1, data_atualizacao = $2
         WHERE id = $3`,
        ['ATIVO', new Date(), beneficiarioId]
      );

      // 5. Alterar status da cobertura para ATIVO
      await client.query(
        `UPDATE "intermit-benefits".tb_cobertura_beneficiario
         SET status = $1, data_atualizacao = $2
         WHERE id = $3`,
        ['ATIVO', new Date(), coberturaId]
      );

      // 6. Inserir registro de utilização de cobertura (Check-in)
      const checkinDate = new Date(body.data_checkin);
      await client.query(
        `INSERT INTO "intermit-benefits".tb_utilizacao_cobertura (
          cobertura_id, contrato_id, check_in, data_criacao
         ) VALUES ($1, $2, $3, $4)`,
        [coberturaId, contratoId, checkinDate, new Date()]
      );

      await client.query('COMMIT');

      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: 'Check-in realizado com sucesso',
          status: 'ATIVO'
        })
      };

    } catch (dbError) {
      await client.query('ROLLBACK');
      throw dbError;
    } finally {
      client.release();
    }

  } catch (error) {
    console.error('Erro ao processar check-in:', error.message);
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
