import { query } from '../../infra/database/postgres.js';

const FILLABLE_FIELDS = [
  'grupo_economico_id',
  'cnae_id',
  'estipulante',
  'razao_social',
  'cpf_cnpj',
  'tipo_doc_complementar',
  'data_fundacao',
  'cliente_desde',
  'corretora_id',
  'estrutura_empresarial',
  'co_corretor_id',
  'consultor_id',
  'gestor_id',
  'participantes_atend',
  'classificacao',
  'status_risco',
  'notif_atualizacao_atend',
  'visualizar_dashboard',
  'enviar_carta_maior_tit',
  'enviar_carta_maior_est',
  'codigo_promid',
  'codigo_apolice_promid',
  'ativo',
  'data_cadastro',
  'data_atualizacao',
  'usuario_cadastro_id'
];

export class Estipulante {
  async create(payload) {
    const fields = [];
    const values = [];
    const placeholders = [];

    FILLABLE_FIELDS.forEach((field) => {
      if (payload[field] !== undefined) {
        fields.push(field);
        values.push(payload[field]);
        placeholders.push(`$${values.length}`);
      }
    });

    if (!fields.includes("data_cadastro")) {
      fields.push("data_cadastro");
      values.push(new Date().toISOString());
      placeholders.push(`$${values.length}`);
    }

    const text = `INSERT INTO tb_estipulante (${fields.join(", ")}) VALUES (${placeholders.join(", ")}) RETURNING *`;
    const result = await query(text, values);

    return result.rows[0];
  }

  async getById(id) {
    const result = await query(`SELECT * FROM tb_estipulante WHERE id = $1`, [id]);
    return result.rows[0] || null;
  }

  async update(id, payload) {
    const fields = [];
    const values = [];

    FILLABLE_FIELDS.forEach((field) => {
      if (field === "data_cadastro") {
        return;
      }
      if (payload[field] !== undefined) {
        values.push(payload[field]);
        fields.push(`${field} = $${values.length}`);
      }
    });

    if (fields.length === 0) {
      throw new Error("Nenhum campo válido para atualizar.");
    }

    values.push(id);
    const text = `UPDATE tb_estipulante SET ${fields.join(", ")} WHERE id = $${values.length} RETURNING *`;
    const result = await query(text, values);

    return result.rows[0] || null;
  }

  async delete(id) {
    const result = await query(`DELETE FROM tb_estipulante WHERE id = $1 RETURNING id`, [id]);
    return result.rows[0] || null;
  }
}
