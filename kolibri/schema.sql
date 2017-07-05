DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `files`;
DROP TABLE IF EXISTS `materials`;
DROP TABLE IF EXISTS `extra_elements`;
DROP TABLE IF EXISTS `custom_sizes`;

CREATE TABLE `customers`
(
  `id` SMALLINT(6) NOT NULL AUTO_INCREMENT
    PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NULL,
  `phone` TEXT NULL,
  `agent` VARCHAR(255) NULL,
  `aliases` TEXT
);

CREATE TABLE `files`
(
  `id` INT NOT NULL AUTO_INCREMENT
    PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `uploaded` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `customer` SMALLINT(6) NOT NULL REFERENCES `customers` (`id`)
    ON DELETE RESTRICT,
  `material` SMALLINT(6) NOT NULL REFERENCES `materials` (`id`)
    ON DELETE RESTRICT,
  `material_price` DOUBLE NOT NULL DEFAULT 0,
  `extra_elements` VARCHAR(255) NULL,
  `extra_price` DOUBLE NOT NULL DEFAULT 0,
  `size` VARCHAR(255) NULL,
  `area` DOUBLE NOT NULL DEFAULT 0,
  `copies` SMALLINT(6) NOT NULL,
  `price` DOUBLE DEFAULT '0' NOT NULL
);

CREATE TABLE `materials`
(
  `id` SMALLINT(6) NOT NULL AUTO_INCREMENT
    PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `price_per_m` DOUBLE NOT NULL,
  `aliases` TEXT
);

CREATE TABLE `extra_elements`
(
  `id` SMALLINT(6) NOT NULL AUTO_INCREMENT
    PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `price_per_one` DOUBLE NOT NULL,
  `aliases` TEXT
);

REPLACE INTO `materials` VALUES
  (1, 'Банер литий', 100, 'baner lutuj'),
  (2, 'Оракал', 100, 'orakal, orokal, oracal, orocal'),
  (3, 'Банер', 80, 'baner, boner, banner'),
  (4, 'Папір', 55, 'paper, papir')
;

REPLACE INTO `extra_elements`
VALUES (1, 'Люверси', 10.5, 'luvers, lyvers'), (2, 'Порізка', 40, 'rizatu, rizka, porizatu');

REPLACE INTO `customers` VALUES (1, '49 Ідей', '', '', 'Вася Пупкін', '49i, 49?'),
  (2, 'Центр Друку', '', '', 'Іван', 'centrdruk, centrdruku, centrdryky')
  , (3, 'Поліграфцентр', '', '', '', 'Poligrafcenter'), (4, 'Максимум', '', '', '', 'maximum'),
  (5, 'Sweet', '', '', '', 'sweet');
