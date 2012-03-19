-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Fri Mar  9 13:08:07 2012
-- 
;
SET foreign_key_checks=0;
--
-- Table: `result`
--
CREATE TABLE `result` (
  `id` integer NOT NULL auto_increment,
  `result_hash` varchar(60) NOT NULL,
  `user` integer DEFAULT null,
  `name` varchar(120),
  `scenario` text NOT NULL,
  `stdin` varchar(200) NOT NULL,
  `cmd` text NOT NULL,
  `stdout` varchar(200) NOT NULL,
  `stderr` varchar(200) NOT NULL,
  `ret` integer NOT NULL DEFAULT 1,
  `last_modified` datetime NOT NULL,
  INDEX `result_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `hash_unique` (`result_hash`),
  CONSTRAINT `result_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `scenario`
--
CREATE TABLE `scenario` (
  `id` integer NOT NULL auto_increment,
  `scenario` text NOT NULL,
  `name` varchar(120) NOT NULL,
  `comment` text,
  `user` integer NOT NULL DEFAULT 0,
  `last_modified` datetime NOT NULL,
  INDEX `scenario_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `name_user_unique` (`name`, `user`),
  CONSTRAINT `scenario_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`)
) ENGINE=InnoDB;
--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer NOT NULL auto_increment,
  `email` text NOT NULL,
  `password` text NOT NULL,
  `last_modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `email_unique` (`email`)
) ENGINE=InnoDB;
SET foreign_key_checks=1