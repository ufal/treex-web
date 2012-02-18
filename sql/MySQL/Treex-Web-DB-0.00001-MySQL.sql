-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sat Feb 18 00:46:05 2012
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `result`;

--
-- Table: `result`
--
CREATE TABLE `result` (
  `id` integer NOT NULL auto_increment,
  `hash` varchar(30) NOT NULL,
  `user` integer DEFAULT null,
  `name` varchar(120) NOT NULL,
  `scenario` text NOT NULL,
  `last_modified` datetime NOT NULL,
  INDEX `result_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `hash_unique` (`hash`),
  CONSTRAINT `result_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user`;

--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer NOT NULL auto_increment,
  `email` varchar(120) NOT NULL,
  `password` varchar(120) NOT NULL,
  `last_modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `email_unique` (`email`)
) ENGINE=InnoDB;

SET foreign_key_checks=1;

