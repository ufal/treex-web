-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Mon Feb  4 17:42:42 2013
-- 

;
BEGIN TRANSACTION;
--
-- Table: language_groups
--
CREATE TABLE language_groups (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(200) NOT NULL,
  position integer
);
--
-- Table: languages
--
CREATE TABLE languages (
  id INTEGER PRIMARY KEY NOT NULL,
  language_group integer NOT NULL,
  code varchar(10) NOT NULL,
  name varchar(120) NOT NULL,
  position integer,
  FOREIGN KEY (language_group) REFERENCES language_groups(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX languages_idx_language_group ON languages (language_group);
--
-- Table: result
--
CREATE TABLE result (
  id INTEGER PRIMARY KEY NOT NULL,
  job_handle varchar(255),
  unique_token varchar(60) NOT NULL,
  user integer DEFAULT null,
  name varchar(120),
  last_modified datetime NOT NULL,
  FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);
CREATE INDEX result_idx_user ON result (user);
CREATE UNIQUE INDEX unique_token ON result (unique_token);
--
-- Table: scenarios
--
CREATE TABLE scenarios (
  id INTEGER PRIMARY KEY NOT NULL,
  scenario text NOT NULL,
  name varchar(120) NOT NULL,
  description text,
  public boolean NOT NULL,
  user integer NOT NULL DEFAULT 0,
  created_at datetime NOT NULL,
  last_modified datetime NOT NULL,
  FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);
CREATE INDEX scenarios_idx_user ON scenarios (user);
CREATE UNIQUE INDEX name_user_unique ON scenarios (name, user);
--
-- Table: user
--
CREATE TABLE user (
  id INTEGER PRIMARY KEY NOT NULL,
  email varchar(120) NOT NULL,
  password char(59) NOT NULL,
  active boolean NOT NULL,
  activate_token char(20),
  last_modified datetime NOT NULL
);
CREATE UNIQUE INDEX email_unique ON user (email);
--
-- Table: scenario_languages
--
CREATE TABLE scenario_languages (
  scenario integer NOT NULL,
  language varchar NOT NULL,
  PRIMARY KEY (scenario, language),
  FOREIGN KEY (language) REFERENCES languages(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (scenario) REFERENCES scenarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX scenario_languages_idx_language ON scenario_languages (language);
CREATE INDEX scenario_languages_idx_scenario ON scenario_languages (scenario);
COMMIT