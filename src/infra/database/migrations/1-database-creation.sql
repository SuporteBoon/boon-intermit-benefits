
CREATE SCHEMA IF NOT EXISTS "intermit-benefits";
SET search_path TO "intermit-benefits";

-- Tabelas de apoio referenciadas na especificação
CREATE TABLE tb_cnae (
 id BIGSERIAL PRIMARY KEY,
 codigo VARCHAR(20) NOT NULL,
 descricao VARCHAR(300) NOT NULL
);

CREATE TABLE tb_operadora (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(200) NOT NULL,
 ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tb_perfil_dados (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 descricao TEXT
);

CREATE TABLE tb_cargo (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(200) NOT NULL,
 ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tb_departamento (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(200) NOT NULL,
 ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tb_perfil (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 descricao TEXT,
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL
);

CREATE TABLE tb_corretora (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(200) NOT NULL,
 razao_social VARCHAR(300) NOT NULL,
 cpf_cnpj VARCHAR(18) NOT NULL,
 data_angariacao DATE,
 lider BOOLEAN,
 corretora_lider_id BIGINT REFERENCES tb_corretora(id),
 autenticacao_dois_fat BOOLEAN,
 cep VARCHAR(9),
 logradouro VARCHAR(300),
 numero VARCHAR(20),
 complemento VARCHAR(100),
 bairro VARCHAR(100),
 cidade VARCHAR(100),
 uf VARCHAR(2),
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ
);

CREATE TABLE tb_co_corretor (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(200) NOT NULL,
 razao_social VARCHAR(300),
 cpf_cnpj VARCHAR(18) NOT NULL,
 codigo_angariador VARCHAR(100),
 classificacao VARCHAR(100),
 email VARCHAR(200),
 telefone VARCHAR(20),
 celular VARCHAR(20),
 cep VARCHAR(9),
 logradouro VARCHAR(300),
 numero VARCHAR(20),
 complemento VARCHAR(100),
 bairro VARCHAR(100),
 cidade VARCHAR(100),
 uf VARCHAR(2),
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL
);

CREATE TABLE tb_grupo_economico (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(200) NOT NULL,
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ,
 usuario_cadastro BIGINT
);

CREATE TABLE tb_estipulante (
 id BIGSERIAL PRIMARY KEY,
 grupo_economico_id BIGINT REFERENCES tb_grupo_economico(id),
 cnae_id BIGINT REFERENCES tb_cnae(id),
 estipulante VARCHAR(200) NOT NULL,
 razao_social VARCHAR(300) NOT NULL,
 cpf_cnpj VARCHAR(18) NOT NULL,
 tipo_doc_complementar VARCHAR(50),
 data_fundacao DATE,
 cliente_desde DATE,
 corretora_id BIGINT REFERENCES tb_corretora(id),
 estrutura_empresarial VARCHAR(100),
 co_corretor_id BIGINT REFERENCES tb_co_corretor(id),
 consultor_id BIGINT,
 gestor_id BIGINT,
 participantes_atend TEXT,
 classificacao VARCHAR(100),
 status_risco VARCHAR(50),
 notif_atualizacao_atend BOOLEAN,
 visualizar_dashboard BOOLEAN,
 enviar_carta_maior_tit BOOLEAN,
 enviar_carta_maior_est BOOLEAN,
 codigo_promid VARCHAR(100),
 codigo_apolice_promid VARCHAR(100),
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ,
 usuario_cadastro_id BIGINT
);

CREATE TABLE tb_subestipulante (
 id BIGSERIAL PRIMARY KEY,
 estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 subestipulante VARCHAR(200) NOT NULL,
 cpf_cnpj VARCHAR(18) NOT NULL,
 tipo_doc_complementar VARCHAR(50),
 data_fundacao DATE,
 cliente_desde DATE,
 codigo_empresa VARCHAR(100),
 codigo_promid VARCHAR(100),
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ,
 usuario_cadastro_id BIGINT
);

CREATE TABLE tb_usuario (
 id BIGSERIAL PRIMARY KEY,
 estipulante_id BIGINT REFERENCES tb_estipulante(id),
 nome_completo VARCHAR(300) NOT NULL,
 cpf VARCHAR(14),
 rg VARCHAR(20),
 data_nascimento DATE,
 responsavel_por_cliente BOOLEAN,
 email VARCHAR(200) NOT NULL,
 senha_hash VARCHAR(500) NOT NULL,
 perfil_dados_id BIGINT REFERENCES tb_perfil_dados(id),
 perfil_id BIGINT NOT NULL REFERENCES tb_perfil(id),
 papeis TEXT NOT NULL,
 permitir_acesso_salarios BOOLEAN,
 permitir_acesso_dashboard BOOLEAN,
 enviar_email_usuario BOOLEAN,
 bloqueado BOOLEAN,
 data_aceite_lgpd TIMESTAMPTZ,
 receber_notif_criticas BOOLEAN,
 corretora_id BIGINT REFERENCES tb_corretora(id),
 codigo_promid VARCHAR(100),
 cargo_id BIGINT REFERENCES tb_cargo(id),
 departamento_id BIGINT REFERENCES tb_departamento(id),
 estrutura_empresarial VARCHAR(100),
 responsavel_imediato_id BIGINT REFERENCES tb_usuario(id),
 telefone VARCHAR(20),
 celular VARCHAR(20),
 telefone_comercial VARCHAR(20),
 ramal VARCHAR(10),
 ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ,
 ultimo_login TIMESTAMPTZ
);

ALTER TABLE tb_grupo_economico ADD CONSTRAINT fk_grupo_usuario FOREIGN KEY (usuario_cadastro) REFERENCES tb_usuario(id);
ALTER TABLE tb_estipulante ADD CONSTRAINT fk_estip_usuario FOREIGN KEY (usuario_cadastro_id) REFERENCES tb_usuario(id);
ALTER TABLE tb_estipulante ADD CONSTRAINT fk_estip_cons FOREIGN KEY (consultor_id) REFERENCES tb_usuario(id);
ALTER TABLE tb_estipulante ADD CONSTRAINT fk_estip_gest FOREIGN KEY (gestor_id) REFERENCES tb_usuario(id);
ALTER TABLE tb_subestipulante ADD CONSTRAINT fk_sub_usuario FOREIGN KEY (usuario_cadastro_id) REFERENCES tb_usuario(id);

CREATE TABLE tb_estipulante_faixa_contribuicao (
 id BIGSERIAL PRIMARY KEY, estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 faixa_inicial NUMERIC(10,2) NOT NULL, faixa_final NUMERIC(10,2) NOT NULL,
 percentual NUMERIC(5,2) NOT NULL, descricao VARCHAR(200), ativo BOOLEAN NOT NULL
);

CREATE TABLE tb_estipulante_contato (
 id BIGSERIAL PRIMARY KEY, estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 tipo_contato VARCHAR(50) NOT NULL, nome VARCHAR(200) NOT NULL, email VARCHAR(200),
 telefone VARCHAR(20), ramal VARCHAR(10), celular VARCHAR(20), cargo VARCHAR(100),
 relevancia VARCHAR(50), nome_secretaria VARCHAR(200), data_aniversario DATE
);

CREATE TABLE tb_estipulante_endereco (
 id BIGSERIAL PRIMARY KEY, estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 tipo_endereco VARCHAR(50) NOT NULL, cep VARCHAR(9) NOT NULL, logradouro VARCHAR(300) NOT NULL,
 numero VARCHAR(20) NOT NULL, complemento VARCHAR(100), bairro VARCHAR(100) NOT NULL,
 cidade VARCHAR(100) NOT NULL, uf VARCHAR(2) NOT NULL
);

CREATE TABLE tb_estipulante_documento (
 id BIGSERIAL PRIMARY KEY, estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 tipo_documento VARCHAR(100) NOT NULL, nome_arquivo VARCHAR(300) NOT NULL,
 caminho VARCHAR(500) NOT NULL, data_upload TIMESTAMPTZ NOT NULL,
 usuario_upload_id BIGINT NOT NULL REFERENCES tb_usuario(id)
);

CREATE TABLE tb_subestipulante_dados_bancarios (
 id BIGSERIAL PRIMARY KEY, subestipulante_id BIGINT NOT NULL REFERENCES tb_subestipulante(id),
 banco VARCHAR(100) NOT NULL, agencia VARCHAR(10) NOT NULL, conta VARCHAR(20) NOT NULL,
 tipo_conta VARCHAR(30) NOT NULL, titular VARCHAR(200) NOT NULL,
 cpf_cnpj_titular VARCHAR(18) NOT NULL, principal BOOLEAN NOT NULL
);

CREATE TABLE tb_subestipulante_contato (
 id BIGSERIAL PRIMARY KEY, subestipulante_id BIGINT NOT NULL REFERENCES tb_subestipulante(id),
 tipo_contato VARCHAR(50) NOT NULL, nome VARCHAR(200) NOT NULL, email VARCHAR(200),
 telefone VARCHAR(20), ramal VARCHAR(10), celular VARCHAR(20), cargo VARCHAR(100),
 relevancia VARCHAR(50), nome_secretaria VARCHAR(200), data_aniversario DATE
);

CREATE TABLE tb_subestipulante_endereco (
 id BIGSERIAL PRIMARY KEY, subestipulante_id BIGINT NOT NULL REFERENCES tb_subestipulante(id),
 tipo_endereco VARCHAR(50) NOT NULL, cep VARCHAR(9) NOT NULL, logradouro VARCHAR(300) NOT NULL,
 numero VARCHAR(20) NOT NULL, complemento VARCHAR(100), bairro VARCHAR(100) NOT NULL,
 cidade VARCHAR(100) NOT NULL, uf VARCHAR(2) NOT NULL
);

CREATE TABLE tb_subestipulante_cargo (
 id BIGSERIAL PRIMARY KEY, subestipulante_id BIGINT NOT NULL REFERENCES tb_subestipulante(id),
 codigo VARCHAR(50) NOT NULL, nome VARCHAR(200) NOT NULL, job_level VARCHAR(100),
 ativo BOOLEAN NOT NULL
);

CREATE TABLE tb_contrato (
 id BIGSERIAL PRIMARY KEY,
 estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 produto VARCHAR(200) NOT NULL,
 operadora_fornecedor_id BIGINT NOT NULL REFERENCES tb_operadora(id),
 sistema_digitacao VARCHAR(100),
 parceiros_adm_beneficios VARCHAR(200),
 contrato_conjugado BOOLEAN,
 codigo_contrato_apolice VARCHAR(100) NOT NULL,
 tipo_cliente VARCHAR(50), tipo_custeio VARCHAR(50), linha_produto VARCHAR(100),
 geracao_auto_faturas BOOLEAN, co_corretor_id BIGINT REFERENCES tb_co_corretor(id),
 consultor_id BIGINT REFERENCES tb_usuario(id),
 codigo_produto_promid VARCHAR(100), codigo_grupo_prod_promid VARCHAR(100),
 data_vigencia_inicio DATE NOT NULL, data_aniversario_contrato DATE,
 vigencia_contrato VARCHAR(50), data_vigencia_final DATE,
 data_inicio_op_corretora DATE, tipo_negocio VARCHAR(50), dia_corte INTEGER,
 dia_liberacao_fatura INTEGER, dia_liberacao_outras_fat INTEGER,
 dia_vencimento_fatura INTEGER, forma_recebimento_faturas VARCHAR(50),
 nao_gerar_tipos_faturam TEXT, tipo_movimentacao VARCHAR(20),
 enviar_carteirinha BOOLEAN, periodo_venc_carteirinha VARCHAR(50),
 descricao TEXT, ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL, data_atualizacao TIMESTAMPTZ,
 usuario_cadastro_id BIGINT NOT NULL REFERENCES tb_usuario(id)
);

CREATE TABLE tb_contrato_produto (
 id BIGSERIAL PRIMARY KEY, contrato_id BIGINT NOT NULL REFERENCES tb_contrato(id),
 break_even_limite_tecnico NUMERIC(5,2), maior_idade INTEGER,
 maior_idade_universitario INTEGER, qtd_vidas_inicial INTEGER,
 tipo_contrato VARCHAR(30), tipo_operacao VARCHAR(30),
 grupo_familiar_planos_div BOOLEAN, multipla_numeracao_cartao BOOLEAN,
 beneficiarios_afastados BOOLEAN, modalidade_contratacao VARCHAR(20),
 preve_upgrade BOOLEAN, preve_downgrade BOOLEAN, contributario BOOLEAN,
 necessita_dps BOOLEAN, aceita_prestadores BOOLEAN, qtd_prestadores INTEGER,
 percentual_prestadores NUMERIC(5,2)
);

CREATE TABLE tb_contrato_subestipulante (
 id BIGSERIAL PRIMARY KEY, contrato_id BIGINT NOT NULL REFERENCES tb_contrato(id),
 subestipulante_id BIGINT NOT NULL REFERENCES tb_subestipulante(id),
 ativa BOOLEAN NOT NULL, data_inicio DATE, codigo_na_operadora VARCHAR(100),
 agrupar_faturamento_a BIGINT REFERENCES tb_subestipulante(id),
 cobranca_agrupada BOOLEAN, codigo_doc_promid VARCHAR(100),
 codigo_apolice_prom_mid VARCHAR(100)
);

CREATE TABLE tb_procedimento (
 id BIGSERIAL PRIMARY KEY, nome VARCHAR(300) NOT NULL,
 categoria VARCHAR(100), ativo BOOLEAN NOT NULL
);

CREATE TABLE tb_plano (
 id BIGSERIAL PRIMARY KEY, contrato_id BIGINT NOT NULL REFERENCES tb_contrato(id),
 operadora_id BIGINT NOT NULL REFERENCES tb_operadora(id),
 produto VARCHAR(200) NOT NULL, codigo VARCHAR(50) NOT NULL,
 cobertura VARCHAR(200), acomodacao VARCHAR(30),
 abrangencia VARCHAR(30), ativo BOOLEAN NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL
);

CREATE TABLE tb_plano_procedimento (
 id BIGSERIAL PRIMARY KEY, plano_id BIGINT NOT NULL REFERENCES tb_plano(id),
 procedimento_id BIGINT NOT NULL REFERENCES tb_procedimento(id),
 ativo BOOLEAN NOT NULL
);

CREATE TABLE tb_faturamento (
 id BIGSERIAL PRIMARY KEY,
 estipulante_id BIGINT NOT NULL REFERENCES tb_estipulante(id),
 operadora_fornecedor_id BIGINT NOT NULL REFERENCES tb_operadora(id),
 contrato_id BIGINT NOT NULL REFERENCES tb_contrato(id),
 subestipulante_id BIGINT REFERENCES tb_subestipulante(id),
 estrutura_empresarial VARCHAR(100), ano_mes_competencia VARCHAR(7) NOT NULL,
 data_inicio_vigencia DATE, data_fim_vigencia DATE, tipo_faturamento VARCHAR(50),
 prorrogacao_fatura BOOLEAN, dia_vencimento INTEGER, data_emissao DATE,
 numero_fatura_endosso VARCHAR(100), valor_fatura_premio_bruto NUMERIC(15,2),
 valor_coparticipacao NUMERIC(15,2), desconto_ajuste NUMERIC(15,2),
 iof NUMERIC(15,2), iss NUMERIC(15,2), valor_premio_liquido NUMERIC(15,2),
 qtd_vidas INTEGER, kit_concluido BOOLEAN,
 data_kit_concluido_email TIMESTAMPTZ, data_integracao TIMESTAMPTZ,
 usuario_integracao_id BIGINT REFERENCES tb_usuario(id),
 numero_alteracao_promid VARCHAR(100), fatura_quitada BOOLEAN,
 fatura_conferida BOOLEAN, data_fatura_conferida TIMESTAMPTZ,
 usuario_fatura_conferida_id BIGINT REFERENCES tb_usuario(id),
 status VARCHAR(30) NOT NULL, data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ, usuario_cadastro_id BIGINT NOT NULL REFERENCES tb_usuario(id)
);

CREATE TABLE tb_parceiro (
 id BIGSERIAL PRIMARY KEY,
 razao_social VARCHAR(300) NOT NULL,
 nome_fantasia VARCHAR(200),
 cnpj VARCHAR(18) NOT NULL,
 token_api VARCHAR(500) NOT NULL,
 webhook_url VARCHAR(500),
 status VARCHAR(30) NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ
);

CREATE TABLE tb_beneficiario (
 id BIGSERIAL PRIMARY KEY,
 nome VARCHAR(300) NOT NULL,
 cpf VARCHAR(14) NOT NULL UNIQUE,
 data_nascimento DATE,
 telefone VARCHAR(20),
 email VARCHAR(200),
 status VARCHAR(30) NOT NULL,
 data_cadastro TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ
);

CREATE TABLE tb_cobertura_beneficiario (
 id BIGSERIAL PRIMARY KEY,
 beneficiario_id BIGINT NOT NULL REFERENCES tb_beneficiario(id),
 contrato_origem_id BIGINT NOT NULL REFERENCES tb_contrato(id),
 data_inicio_cobertura DATE NOT NULL,
 data_fim_cobertura DATE NOT NULL,
 valor_cobrado NUMERIC(15,2),
 status VARCHAR(30) NOT NULL,
 data_criacao TIMESTAMPTZ NOT NULL,
 data_atualizacao TIMESTAMPTZ
);

CREATE TABLE tb_utilizacao_cobertura (
 id BIGSERIAL PRIMARY KEY,
 cobertura_id BIGINT NOT NULL REFERENCES tb_cobertura_beneficiario(id),
 contrato_id BIGINT NOT NULL REFERENCES tb_contrato(id),
 check_in TIMESTAMPTZ NOT NULL,
 check_out TIMESTAMPTZ,
 data_criacao TIMESTAMPTZ NOT NULL
);

CREATE TABLE tb_previsao_financeira (
 id BIGSERIAL PRIMARY KEY,
 beneficiario_id BIGINT NOT NULL REFERENCES tb_beneficiario(id),
 cobertura_id BIGINT NOT NULL REFERENCES tb_cobertura_beneficiario(id),
 competencia VARCHAR(7) NOT NULL,
 valor NUMERIC(15,2) NOT NULL,
 status VARCHAR(20) NOT NULL,
 data_geracao TIMESTAMPTZ NOT NULL,
 data_conversao TIMESTAMPTZ,
 faturamento_id BIGINT REFERENCES tb_faturamento(id)
);

CREATE TABLE tb_log_integracao (
 id BIGSERIAL PRIMARY KEY,
 origem VARCHAR(50) NOT NULL,
 tipo_evento VARCHAR(100) NOT NULL,
 beneficiario_id BIGINT REFERENCES tb_beneficiario(id),
 cobertura_id BIGINT REFERENCES tb_cobertura_beneficiario(id),
 payload_enviado TEXT,
 payload_retorno TEXT,
 status VARCHAR(30) NOT NULL,
 codigo_http INTEGER,
 mensagem_erro TEXT,
 data_hora TIMESTAMPTZ NOT NULL,
 tempo_resposta_ms INTEGER
);

CREATE TABLE tb_auditoria (
 id BIGSERIAL PRIMARY KEY,
 usuario_id BIGINT NOT NULL REFERENCES tb_usuario(id),
 data_hora TIMESTAMPTZ NOT NULL,
 operacao VARCHAR(30) NOT NULL,
 entidade VARCHAR(100) NOT NULL,
 registro_id BIGINT,
 campo VARCHAR(100),
 valor_anterior TEXT,
 valor_novo TEXT,
 ip_origem VARCHAR(45) NOT NULL,
 user_agent VARCHAR(500),
 dados_extras TEXT
);

CREATE TABLE tb_perfil_permissao_campo (
 id BIGSERIAL PRIMARY KEY,
 perfil_id BIGINT NOT NULL REFERENCES tb_perfil(id),
 entidade VARCHAR(100) NOT NULL,
 campo VARCHAR(100) NOT NULL,
 pode_ler BOOLEAN NOT NULL,
 pode_editar BOOLEAN NOT NULL,
 pode_gravar BOOLEAN NOT NULL,
 ativo BOOLEAN NOT NULL
);
