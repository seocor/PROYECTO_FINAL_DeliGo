-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         12.2.2-MariaDB - MariaDB Server
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.14.0.7165
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para bdadeligo
CREATE DATABASE IF NOT EXISTS `bdadeligo` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `bdadeligo`;

-- Volcando estructura para tabla bdadeligo.alergenos
CREATE TABLE IF NOT EXISTS `alergenos` (
  `id_alergeno` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_alergeno`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.alergenos: ~10 rows (aproximadamente)
INSERT INTO `alergenos` (`id_alergeno`, `nombre`) VALUES
	(1, 'Gluten'),
	(2, 'Lácteos'),
	(3, 'Huevo'),
	(4, 'Pescado'),
	(5, 'Marisco'),
	(6, 'Soja'),
	(7, 'Sésamo'),
	(8, 'Cacahuetes'),
	(9, 'Frutos secos'),
	(10, 'Mostaza');

-- Volcando estructura para tabla bdadeligo.auditoria_pedidos
CREATE TABLE IF NOT EXISTS `auditoria_pedidos` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `estado_antes` varchar(50) DEFAULT NULL,
  `estado_despues` varchar(50) DEFAULT NULL,
  `usuario_cambio` varchar(150) DEFAULT NULL,
  `fecha_cambio` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.auditoria_pedidos: ~0 rows (aproximadamente)

-- Volcando estructura para procedimiento bdadeligo.calcular_total_pedido
DELIMITER //
CREATE PROCEDURE `calcular_total_pedido`(IN p_id_pedido INT)
BEGIN
    DECLARE v_sub     DECIMAL(8,2);
    DECLARE v_envio   DECIMAL(6,2) DEFAULT 1.99;
    DECLARE v_iva     DECIMAL(6,2);
    DECLARE v_total   DECIMAL(8,2);

    SELECT COALESCE(SUM(subtotal), 0) INTO v_sub
    FROM lineas_pedido WHERE id_pedido = p_id_pedido;

    SET v_iva   = ROUND(v_sub * 0.10, 2);
    SET v_total = v_sub + v_envio + v_iva;

    UPDATE pedidos SET total = v_total WHERE id_pedido = p_id_pedido;

    SELECT v_sub AS subtotal, v_envio AS envio, v_iva AS iva_10pct, v_total AS total;
END//
DELIMITER ;

-- Volcando estructura para tabla bdadeligo.categorias
CREATE TABLE IF NOT EXISTS `categorias` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.categorias: ~7 rows (aproximadamente)
INSERT INTO `categorias` (`id_categoria`, `nombre`, `descripcion`, `activa`) VALUES
	(1, 'Hamburguesas', NULL, 1),
	(2, 'Pizzas', NULL, 1),
	(3, 'Bowls', NULL, 1),
	(4, 'Ramen', NULL, 1),
	(5, 'Tacos', NULL, 1),
	(6, 'Postres', NULL, 1),
	(7, 'Asiático', NULL, 1);

-- Volcando estructura para tabla bdadeligo.direcciones
CREATE TABLE IF NOT EXISTS `direcciones` (
  `id_direccion` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `calle` varchar(200) NOT NULL,
  `numero` varchar(10) NOT NULL,
  `piso` varchar(20) DEFAULT NULL,
  `ciudad` varchar(100) NOT NULL,
  `codigo_postal` varchar(10) NOT NULL,
  `principal` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_direccion`),
  KEY `fk_dir_usr` (`id_usuario`),
  CONSTRAINT `fk_dir_usr` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.direcciones: ~3 rows (aproximadamente)
INSERT INTO `direcciones` (`id_direccion`, `id_usuario`, `calle`, `numero`, `piso`, `ciudad`, `codigo_postal`, `principal`) VALUES
	(1, 1, 'Calle Mayor', '12', NULL, 'Valencia', '46001', 1),
	(2, 3, 'Avda. de la Paz', '45A', NULL, 'Valencia', '46002', 1),
	(3, 4, 'Calle Colón', '7', NULL, 'Valencia', '46004', 1);

-- Volcando estructura para tabla bdadeligo.lineas_pedido
CREATE TABLE IF NOT EXISTS `lineas_pedido` (
  `id_linea` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `id_plato` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1 CHECK (`cantidad` > 0),
  `precio_unidad` decimal(6,2) NOT NULL,
  `subtotal` decimal(8,2) GENERATED ALWAYS AS (`cantidad` * `precio_unidad`) STORED,
  PRIMARY KEY (`id_linea`),
  KEY `fk_lp_pedido` (`id_pedido`),
  KEY `fk_lp_plato` (`id_plato`),
  CONSTRAINT `fk_lp_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `fk_lp_plato` FOREIGN KEY (`id_plato`) REFERENCES `platos` (`id_plato`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.lineas_pedido: ~5 rows (aproximadamente)
INSERT INTO `lineas_pedido` (`id_linea`, `id_pedido`, `id_plato`, `cantidad`, `precio_unidad`) VALUES
	(1, 1, 1, 1, 12.90),
	(2, 1, 2, 2, 11.50),
	(3, 2, 9, 1, 15.50),
	(4, 3, 4, 1, 14.50),
	(5, 4, 7, 3, 13.20);

-- Volcando estructura para tabla bdadeligo.pedidos
CREATE TABLE IF NOT EXISTS `pedidos` (
  `id_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `id_direccion` int(11) NOT NULL DEFAULT 1,
  `id_repartidor` int(11) DEFAULT NULL,
  `estado` enum('recibido','preparando','en_camino','entregado','cancelado') NOT NULL DEFAULT 'recibido',
  `fecha_pedido` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_entrega` datetime DEFAULT NULL,
  `total` decimal(8,2) NOT NULL DEFAULT 0.00,
  `notas` text DEFAULT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `fk_ped_usr` (`id_usuario`),
  KEY `fk_ped_dir` (`id_direccion`),
  KEY `fk_ped_rep` (`id_repartidor`),
  CONSTRAINT `fk_ped_dir` FOREIGN KEY (`id_direccion`) REFERENCES `direcciones` (`id_direccion`),
  CONSTRAINT `fk_ped_rep` FOREIGN KEY (`id_repartidor`) REFERENCES `repartidores` (`id_repartidor`),
  CONSTRAINT `fk_ped_usr` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.pedidos: ~4 rows (aproximadamente)
INSERT INTO `pedidos` (`id_pedido`, `id_usuario`, `id_direccion`, `id_repartidor`, `estado`, `fecha_pedido`, `fecha_entrega`, `total`, `notas`) VALUES
	(1, 1, 1, 1, 'entregado', '2026-04-30 09:27:12', NULL, 38.28, NULL),
	(2, 1, 1, 1, 'en_camino', '2026-04-30 09:27:12', NULL, 16.48, NULL),
	(3, 1, 1, 2, 'recibido', '2026-04-30 09:27:12', NULL, 14.49, NULL),
	(4, 5, 1, 1, 'recibido', '2026-04-30 12:38:10', NULL, 45.55, NULL);

-- Volcando estructura para tabla bdadeligo.plato_alergeno
CREATE TABLE IF NOT EXISTS `plato_alergeno` (
  `id_plato` int(11) NOT NULL,
  `id_alergeno` int(11) NOT NULL,
  PRIMARY KEY (`id_plato`,`id_alergeno`),
  KEY `fk_pa_alergeno` (`id_alergeno`),
  CONSTRAINT `fk_pa_alergeno` FOREIGN KEY (`id_alergeno`) REFERENCES `alergenos` (`id_alergeno`) ON DELETE CASCADE,
  CONSTRAINT `fk_pa_plato` FOREIGN KEY (`id_plato`) REFERENCES `platos` (`id_plato`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.plato_alergeno: ~33 rows (aproximadamente)
INSERT INTO `plato_alergeno` (`id_plato`, `id_alergeno`) VALUES
	(1, 1),
	(1, 2),
	(1, 3),
	(1, 10),
	(2, 7),
	(3, 1),
	(3, 2),
	(4, 1),
	(4, 3),
	(4, 6),
	(4, 7),
	(5, 1),
	(5, 2),
	(5, 4),
	(6, 1),
	(6, 2),
	(6, 3),
	(7, 5),
	(7, 6),
	(7, 8),
	(8, 1),
	(8, 9),
	(9, 1),
	(9, 2),
	(9, 10),
	(10, 1),
	(10, 2),
	(10, 3),
	(11, 1),
	(11, 6),
	(11, 7),
	(12, 1),
	(12, 2);

-- Volcando estructura para tabla bdadeligo.platos
CREATE TABLE IF NOT EXISTS `platos` (
  `id_plato` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(6,2) NOT NULL CHECK (`precio` >= 0),
  `id_categoria` int(11) NOT NULL,
  `emoji` varchar(10) DEFAULT '?️',
  `calorias` int(11) DEFAULT NULL CHECK (`calorias` >= 0),
  `proteinas` decimal(5,2) DEFAULT NULL CHECK (`proteinas` >= 0),
  `carbohidratos` decimal(5,2) DEFAULT NULL CHECK (`carbohidratos` >= 0),
  `grasas` decimal(5,2) DEFAULT NULL CHECK (`grasas` >= 0),
  `vegetariano` tinyint(1) NOT NULL DEFAULT 0,
  `picante` tinyint(1) NOT NULL DEFAULT 0,
  `disponible` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_alta` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_plato`),
  KEY `fk_plato_cat` (`id_categoria`),
  CONSTRAINT `fk_plato_cat` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.platos: ~12 rows (aproximadamente)
INSERT INTO `platos` (`id_plato`, `nombre`, `descripcion`, `precio`, `id_categoria`, `emoji`, `calorias`, `proteinas`, `carbohidratos`, `grasas`, `vegetariano`, `picante`, `disponible`, `fecha_alta`) VALUES
	(1, 'Burger Clásica', 'Ternera Angus 180g, queso cheddar madurado, bacon ahumado, lechuga iceberg y salsa especial en pan brioche.', 12.90, 1, '🍔', 680, 38.00, 52.00, 32.00, 0, 0, 1, '2026-04-30 09:27:11'),
	(2, 'Bowl Vegano', 'Quinoa ecológica, garbanzos especiados, aguacate, tomates cherry, remolacha asada y aliño de tahini.', 11.50, 3, '🥗', 420, 18.00, 55.00, 14.00, 1, 0, 1, '2026-04-30 09:27:11'),
	(3, 'Pizza Napolitana', 'Masa madre 48h, tomate San Marzano DOP, mozzarella di bufala, albahaca fresca y aceite EVOO.', 13.90, 2, '🍕', 780, 32.00, 90.00, 28.00, 1, 0, 1, '2026-04-30 09:27:11'),
	(4, 'Ramen Tonkotsu', 'Caldo de cerdo cocinado 18h, chashu de panceta glaseado, huevo marinado, nori y aceite de sésamo.', 14.50, 4, '🍜', 620, 42.00, 68.00, 18.00, 0, 1, 1, '2026-04-30 09:27:11'),
	(5, 'Tacos de Baja', '3 tacos con pescado rebozado estilo Baja California, col morada, pico de gallo y jalapeños.', 10.90, 5, '🌮', 510, 28.00, 58.00, 16.00, 0, 1, 1, '2026-04-30 09:27:11'),
	(6, 'Tiramisú Artesano', 'Bizcocho soletilla, mascarpone, espresso y cacao puro en polvo.', 5.90, 6, '🍰', 380, 8.00, 42.00, 20.00, 1, 0, 1, '2026-04-30 09:27:11'),
	(7, 'Pad Thai Gambas', 'Fideos de arroz salteados con gambas, tofu, brotes de soja, cacahuetes y salsa de tamarindo.', 13.20, 7, '🍝', 560, 30.00, 75.00, 14.00, 0, 1, 1, '2026-04-30 09:27:11'),
	(8, 'Açaí Bowl', 'Açaí amazónico, plátano, fresas, granola artesanal, coco tostado y miel de milflores.', 9.50, 3, '🫐', 320, 6.00, 58.00, 8.00, 1, 0, 1, '2026-04-30 09:27:11'),
	(9, 'Smash Burger Doble', 'Doble smash de ternera 100g c/u, queso american doble, pepinillos, cebolla caramelizada.', 15.50, 1, '🍔', 890, 54.00, 60.00, 46.00, 0, 0, 1, '2026-04-30 09:27:11'),
	(10, 'Cheesecake NY', 'Tarta de queso estilo Nueva York, base de galleta, crema philadelphia y coulis de frutos rojos.', 6.50, 6, '🧁', 420, 9.00, 48.00, 22.00, 1, 0, 1, '2026-04-30 09:27:11'),
	(11, 'Gyozas Cerdo', '8 gyozas de cerdo y col con salsa ponzu. Cocinadas al vapor y marcadas en sartén.', 8.90, 7, '🥟', 340, 18.00, 36.00, 12.00, 0, 0, 1, '2026-04-30 09:27:11'),
	(12, 'Pizza BBQ Pollo', 'Base BBQ artesanal, mozzarella, pollo a la brasa, cebolla morada, jalapeños y cilantro.', 14.90, 2, '🍕', 820, 38.00, 88.00, 30.00, 0, 1, 1, '2026-04-30 09:27:11');

-- Volcando estructura para tabla bdadeligo.repartidores
CREATE TABLE IF NOT EXISTS `repartidores` (
  `id_repartidor` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `vehiculo` varchar(100) DEFAULT NULL,
  `matricula` varchar(20) DEFAULT NULL,
  `disponible` tinyint(1) NOT NULL DEFAULT 1,
  `valoracion` decimal(3,2) DEFAULT 5.00 CHECK (`valoracion` between 0 and 5),
  PRIMARY KEY (`id_repartidor`),
  UNIQUE KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `fk_rep_usr` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.repartidores: ~2 rows (aproximadamente)
INSERT INTO `repartidores` (`id_repartidor`, `id_usuario`, `vehiculo`, `matricula`, `disponible`, `valoracion`) VALUES
	(1, 3, 'Honda CBR125', '1234-ABC', 1, 5.00),
	(2, 4, 'Bici eléctrica', 'BE-0042', 1, 5.00);

-- Volcando estructura para vista bdadeligo.resumen_pedidos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `resumen_pedidos` (
	`id_pedido` INT(11) NOT NULL,
	`cliente` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`email` VARCHAR(1) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`estado` ENUM('recibido','preparando','en_camino','entregado','cancelado') NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`fecha_pedido` DATETIME NOT NULL,
	`total` DECIMAL(8,2) NOT NULL,
	`num_platos` BIGINT(21) NOT NULL,
	`repartidor` VARCHAR(1) NULL COLLATE 'utf8mb4_unicode_ci'
);

-- Volcando estructura para tabla bdadeligo.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.roles: ~3 rows (aproximadamente)
INSERT INTO `roles` (`id_rol`, `nombre`, `descripcion`) VALUES
	(1, 'cliente', 'Usuario que realiza pedidos'),
	(2, 'admin', 'Administrador de la plataforma'),
	(3, 'repartidor', 'Repartidor de pedidos');

-- Volcando estructura para tabla bdadeligo.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `id_rol` int(11) NOT NULL DEFAULT 1,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_alta` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_usr_rol` (`id_rol`),
  CONSTRAINT `fk_usr_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.usuarios: ~5 rows (aproximadamente)
INSERT INTO `usuarios` (`id_usuario`, `nombre`, `apellidos`, `email`, `password`, `telefono`, `id_rol`, `activo`, `fecha_alta`) VALUES
	(1, 'María', 'García López', 'cliente@foodrush.com', '1234', '600111222', 1, 1, '2026-04-30 09:27:11'),
	(2, 'Admin', 'FoodRush', 'admin@foodrush.com', '123456789s', '600333444', 2, 1, '2026-04-30 09:27:11'),
	(3, 'Javier', 'Morales Ruiz', 'javier@foodrush.com', '987654321s', '600555666', 3, 1, '2026-04-30 09:27:11'),
	(4, 'Ainhoa', 'Torres Sanz', 'ainhoa@foodrush.com', '987654321s', '600777888', 3, 1, '2026-04-30 09:27:11'),
	(5, 'sergio', 'nose', 'seocor@gmail.com', '$2a$12$e/7Nat84lG8sp9fHmWw0TOc3sDbpB0hLCCeHu.UQ1wzyS8gFnL/GK', NULL, 1, 1, '2026-04-30 10:49:57');

-- Volcando estructura para tabla bdadeligo.valoraciones
CREATE TABLE IF NOT EXISTS `valoraciones` (
  `id_valoracion` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `puntuacion` tinyint(4) NOT NULL CHECK (`puntuacion` between 1 and 5),
  `comentario` text DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_valoracion`),
  UNIQUE KEY `id_pedido` (`id_pedido`),
  KEY `fk_val_usr` (`id_usuario`),
  CONSTRAINT `fk_val_ped` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`),
  CONSTRAINT `fk_val_usr` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla bdadeligo.valoraciones: ~1 rows (aproximadamente)
INSERT INTO `valoraciones` (`id_valoracion`, `id_pedido`, `id_usuario`, `puntuacion`, `comentario`, `fecha`) VALUES
	(1, 1, 1, 5, 'Todo perfecto, llegó caliente y en tiempo. ¡Repetiré seguro!', '2026-04-30 09:27:12');

-- Volcando estructura para disparador bdadeligo.trg_auditoria_estado
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER trg_auditoria_estado
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO auditoria_pedidos
            (id_pedido, estado_antes, estado_despues, usuario_cambio)
        VALUES
            (NEW.id_pedido, OLD.estado, NEW.estado, USER());
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `resumen_pedidos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `resumen_pedidos` AS SELECT
    p.id_pedido,
    CONCAT(u.nombre, ' ', u.apellidos)          AS cliente,
    u.email,
    p.estado,
    p.fecha_pedido,
    p.total,
    COUNT(lp.id_linea)                           AS num_platos,
    CONCAT(ru.nombre, ' ', ru.apellidos)         AS repartidor
FROM pedidos p
JOIN  usuarios u           ON p.id_usuario    = u.id_usuario
JOIN  lineas_pedido lp     ON p.id_pedido     = lp.id_pedido
LEFT JOIN repartidores rep ON p.id_repartidor = rep.id_repartidor
LEFT JOIN usuarios ru      ON rep.id_usuario  = ru.id_usuario
GROUP BY p.id_pedido, u.nombre, u.apellidos, u.email,
         p.estado, p.fecha_pedido, p.total,
         ru.nombre, ru.apellidos 
;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
