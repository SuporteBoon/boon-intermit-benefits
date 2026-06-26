'use strict';

import { Estipulante } from '../../../classes/estipulante/estipulante.js';

export const handler = async (event) => {
  try {
    const id = event.pathParameters?.id;
    if (!id) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: 'ID do estipulante é obrigatório.' })
      };
    }

    const body = event.body ? JSON.parse(event.body) : {};
    const service = new Estipulante();
    const item = await service.update(id, body);

    if (!item) {
      return {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: 'Estipulante não encontrado para atualização.' })
      };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(item)
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: error.message || 'Erro ao atualizar estipulante.' })
    };
  }
};
