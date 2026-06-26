"use strict";
import { Estipulante } from "../../../classes/estipulante/estipulante.js";

exports.handler = async (event) => {
  try {
    const id = event.pathParameters?.id;
    if (!id) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: "ID do estipulante é obrigatório." }),
      };
    }

    const service = new Estipulante();
    const item = await service.getById(id);

    if (!item) {
      return {
        statusCode: 404,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: "Estipulante não encontrado." }),
      };
    }

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(item),
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: error.message || "Erro ao buscar estipulante.",
      }),
    };
  }
};
