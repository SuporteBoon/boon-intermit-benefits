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

    const service = new Estipulante();
    const item = await service.delete(id);

    if (!item) {
      return {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: 'Estipulante não encontrado para remoção.' })
      };
    }

    return {
      statusCode: 204,
      headers: { 'Content-Type': 'application/json' },
      body: ''
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: error.message || 'Erro ao excluir estipulante.' })
    };
  }
};
