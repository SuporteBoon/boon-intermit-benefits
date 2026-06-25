import pkg from "pg";

const { Pool } = pkg;
// O Pool deve ser criado fora do handler para ser reutilizado entre execuções da Lambda (Warm Start)
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 5432,
  max: 1, // No Serverless, 1 conexão por instância é o ideal
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  ssl: {
    rejectUnauthorized: false,
  },
});

export const query = (text, params) => pool.query(text, params);
