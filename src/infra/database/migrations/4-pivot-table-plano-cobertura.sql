CREATE TABLE tb_plano_cobertura (
    plano_id BIGINT NOT NULL,
    cobertura_id BIGINT NOT NULL,

    PRIMARY KEY (plano_id, cobertura_id),

    CONSTRAINT fk_pc_plano
        FOREIGN KEY (plano_id)
        REFERENCES tb_plano(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pc_cobertura
        FOREIGN KEY (cobertura_id)
        REFERENCES tb_cobertura(id)
        ON DELETE CASCADE
);