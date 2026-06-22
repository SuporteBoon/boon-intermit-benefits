'use strict';


exports.handler = async (event) => {
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


    console.log(`Payload validado com sucesso para o CPF: ${body.cpf_segurado}`);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: 'Adesão recebida e validada com sucesso',
        status: 'AGUARDANDO_CHECKIN'
      })
    };

  } catch (error) {
    console.error('Erro estrutural ao processar payload:', error.message);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Internal Server Error' })
    };
  }
};