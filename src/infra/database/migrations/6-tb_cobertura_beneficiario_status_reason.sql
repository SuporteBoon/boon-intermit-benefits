BEGIN;

SET search_path TO "intermit-benefits";

ALTER TABLE tb_cobertura_beneficiario
ADD COLUMN status_reason TEXT;

COMMIT;