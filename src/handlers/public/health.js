'use strict';

exports.handler = async (event) => {
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      status: 'ok',
      message: 'Boon Integration API is running securely',
      timestamp: new Date().toISOString()
    })
  };
};