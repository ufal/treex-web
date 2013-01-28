-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Jan 28 23:50:03 2013
-- 
;
SET foreign_key_checks=0;
--
-- Table: `result`
--
CREATE TABLE `result` (
  `id` integer NOT NULL auto_increment,
  `job_uid` varchar(60) NOT NULL,
  `session` varchar(100) NOT NULL,
  `user` integer DEFAULT null,
  `name` varchar(120),
  `last_modified` datetime NOT NULL,
  INDEX `result_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `hash_unique` (`job_uid`),
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
  `public` enum('0','1') NOT NULL,
  `user` integer NOT NULL DEFAULT 0,
  `last_modified` datetime NOT NULL,
  INDEX `scenario_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `name_user_unique` (`name`, `user`),
  CONSTRAINT `scenario_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer NOT NULL auto_increment,
  `email` varchar(120) NOT NULL,
  `password` char(59) NOT NULL,
  `active` enum('0','1') NOT NULL,
  `activate_token` char(20),
  `last_modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `email_unique` (`email`)
) ENGINE=InnoDB;
SET foreign_key_checks=1