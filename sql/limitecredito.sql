-- Configurações iniciais de segurança
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, 
    SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema elysium
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `limite_credito_agro` 
    DEFAULT CHARACTER SET utf8mb4 
    COLLATE utf8mb4_0900_ai_ci;

USE `limite_credito_agro`;

-- -----------------------------------------------------
-- Table elysium.cliente
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cliente` (
    `cliente_id` INT NOT NULL,
    `nome` VARCHAR(80) NULL DEFAULT NULL,
    `tipo_pessoa` ENUM('PF', 'PJ') NULL DEFAULT NULL,
    `renda_mensal` DECIMAL(15,2) NULL DEFAULT NULL,
    `grupo_familiar_renda` DECIMAL(15,2) NULL DEFAULT NULL,
    `negatvado` TINYINT(1) NULL DEFAULT NULL,
    PRIMARY KEY (`cliente_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table elysium.produto_agro
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `produto_agro` (
    `produto_id` INT NOT NULL,
    `nome_produto` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`produto_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table elysium.cliente_produto
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cliente_produto` (
    `cliente_produto_id` INT NOT NULL,
    `cliente_id` INT NULL DEFAULT NULL,
    `produto_id` INT NULL DEFAULT NULL,
    PRIMARY KEY (`cliente_produto_id`),
    INDEX `cliente_id` (`cliente_id` ASC) VISIBLE,
    INDEX `produto_id` (`produto_id` ASC) VISIBLE,
    CONSTRAINT `cliente_produto_ibfk_1` 
        FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`cliente_id`),
    CONSTRAINT `cliente_produto_ibfk_2` 
        FOREIGN KEY (`produto_id`) REFERENCES `produto_agro` (`produto_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table elysium.endereco
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `endereco` (
    `endereco_id` INT NOT NULL,
    `cliente_id` INT NULL DEFAULT NULL,
    `tipo` VARCHAR(50) NULL DEFAULT NULL,
    `zona` VARCHAR(50) NULL DEFAULT NULL,
    `cep` VARCHAR(20) NULL DEFAULT NULL,
    PRIMARY KEY (`endereco_id`),
    INDEX `cliente_id` (`cliente_id` ASC) VISIBLE,
    CONSTRAINT `endereco_ibfk_1` 
        FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`cliente_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table elysium.limite_credito
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `limite_credito` (
    `limite_id` DECIMAL(15,2) NOT NULL,
    `cliente_id` INT NULL DEFAULT NULL,
    `valor_limite_aprovado` DECIMAL(15,2) NOT NULL,
    `valor_limite_contratado` DECIMAL(15,2) NULL DEFAULT NULL,
    `data_referencia` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`limite_id`),
    INDEX `cliente_id` (`cliente_id` ASC) VISIBLE,
    CONSTRAINT `limite_credito_ibfk_1` 
        FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`cliente_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table elysium.negativacao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `negativacao` (
    `negativacao_id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `negativacao` TINYINT(1) NULL DEFAULT NULL,
    `negativado` TINYINT(1) NULL DEFAULT NULL,
    `possui_apontamentos` TINYINT(1) NULL DEFAULT NULL,
    `limite_comprometido` TINYINT(1) NULL DEFAULT NULL,
    `data_atualizacao` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`negativacao_id`),
    INDEX `fk_negativacao_cliente` (`cliente_id` ASC) VISIBLE,
    CONSTRAINT `fk_negativacao_cliente` 
        FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`cliente_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------
-- Table elysium.propriedades
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `propriedades` (
    `prop_id` INT NOT NULL,
    `cliente_id` INT NULL DEFAULT NULL,
    `descricao` VARCHAR(200) NULL DEFAULT NULL,
    `valor` DECIMAL(15,2) NULL DEFAULT NULL,
    PRIMARY KEY (`prop_id`),
    INDEX `cliente_id` (`cliente_id` ASC) VISIBLE,
    CONSTRAINT `propriedades_ibfk_1` 
        FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`cliente_id`)
) ENGINE = InnoDB 
  DEFAULT CHARACTER SET = utf8mb4 
  COLLATE = utf8mb4_0900_ai_ci;

-- Restaurar configurações originais
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
