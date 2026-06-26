'use strict';

import { Estipulante } from '../../../classes/estipulante/estipulante.js';

export const handler = async (event) => {
  try {
    const body = event.body ? JSON.parse(event.body) : {};
    const service = new Estipulante();
    const item = await service.create(body);

    return {
      statusCode: 201,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(item)
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: error.message || 'Erro ao criar estipulante.' })
    };
  }
};
