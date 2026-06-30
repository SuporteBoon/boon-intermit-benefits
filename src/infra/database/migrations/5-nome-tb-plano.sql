BEGIN;

SET search_path TO "intermit-benefits";

ALTER TABLE tb_plano
ADD COLUMN nome VARCHAR(200);

COMMIT;