BEGIN;

SET search_path TO "intermit-benefits";

-- Remover a FK antiga de tb_plano -> tb_contrato
ALTER TABLE tb_plano
DROP CONSTRAINT IF EXISTS tb_plano_contrato_id_fkey;

-- Remover contrato_id de tb_plano
ALTER TABLE tb_plano
DROP COLUMN IF EXISTS contrato_id;

-- Remover produto textual do contrato
ALTER TABLE tb_contrato
DROP COLUMN IF EXISTS produto;

-- Adicionar referência ao plano
ALTER TABLE tb_contrato
ADD COLUMN plano_id BIGINT;

ALTER TABLE tb_contrato
ADD CONSTRAINT fk_contrato_plano
FOREIGN KEY (plano_id)
REFERENCES tb_plano(id);

-- Remover cobertura textual do plano
ALTER TABLE tb_plano
DROP COLUMN IF EXISTS cobertura;

-- Criar tabela de coberturas
CREATE TABLE tb_cobertura (
    id BIGSERIAL PRIMARY KEY,
    plano_id BIGINT NOT NULL,
    nome VARCHAR(200),
    descricao TEXT,
    ativo BOOLEAN,
    data_cadastro TIMESTAMPTZ,

    CONSTRAINT fk_cobertura_plano
        FOREIGN KEY (plano_id)
        REFERENCES tb_plano(id)
        ON DELETE CASCADE
);


COMMIT;
