-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sun Jun 30 18:04:32 2013
-- 
;
SET foreign_key_checks=0;
--
-- Table: `language_groups`
--
CREATE TABLE `language_groups` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(200) NOT NULL,
  `position` integer NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `languages`
--
CREATE TABLE `languages` (
  `id` integer NOT NULL auto_increment,
  `language_group` integer NOT NULL,
  `code` varchar(10) NOT NULL,
  `name` varchar(120) NOT NULL,
  `position` integer NULL,
  INDEX `languages_idx_language_group` (`language_group`),
  PRIMARY KEY (`id`),
  CONSTRAINT `languages_fk_language_group` FOREIGN KEY (`language_group`) REFERENCES `language_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer NOT NULL auto_increment,
  `email` varchar(120) NOT NULL,
  `name` varchar(120) NOT NULL,
  `password` char(59) NOT NULL,
  `is_admin` enum('0','1') NOT NULL,
  `active` enum('0','1') NOT NULL,
  `activate_token` char(20) NULL,
  `last_modified` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `email_unique` (`email`)
) ENGINE=InnoDB;
--
-- Table: `result`
--
CREATE TABLE `result` (
  `id` integer NOT NULL auto_increment,
  `job_handle` varchar(255) NULL,
  `unique_token` varchar(60) NOT NULL,
  `user` integer NULL DEFAULT null,
  `name` varchar(120) NULL,
  `language` integer NULL,
  `last_modified` datetime NOT NULL,
  INDEX `result_idx_language` (`language`),
  INDEX `result_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `unique_token` (`unique_token`),
  CONSTRAINT `result_fk_language` FOREIGN KEY (`language`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `result_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `scenarios`
--
CREATE TABLE `scenarios` (
  `id` integer NOT NULL auto_increment,
  `scenario` text NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text NULL,
  `public` enum('0','1') NOT NULL,
  `user` integer NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  `last_modified` datetime NOT NULL,
  INDEX `scenarios_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `name_user_unique` (`name`, `user`),
  CONSTRAINT `scenarios_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `scenario_languages`
--
CREATE TABLE `scenario_languages` (
  `scenario` integer NOT NULL,
  `language` varchar(255) NOT NULL,
  INDEX `scenario_languages_idx_language` (`language`),
  INDEX `scenario_languages_idx_scenario` (`scenario`),
  PRIMARY KEY (`scenario`, `language`),
  CONSTRAINT `scenario_languages_fk_language` FOREIGN KEY (`language`) REFERENCES `languages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `scenario_languages_fk_scenario` FOREIGN KEY (`scenario`) REFERENCES `scenarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
