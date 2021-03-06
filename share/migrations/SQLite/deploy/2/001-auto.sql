-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Dec 19 01:05:48 2013
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
-- Table: user
--
CREATE TABLE user (
  id INTEGER PRIMARY KEY NOT NULL,
  persistent_token varchar(120) NOT NULL,
  organization varchar(120) NOT NULL,
  first_name varchar(120),
  last_name varchar(120),
  email varchar(120),
  password char(59),
  is_admin boolean NOT NULL,
  active boolean NOT NULL,
  activate_token char(20),
  last_modified datetime NOT NULL
);
CREATE UNIQUE INDEX token_unique ON user (persistent_token);
--
-- Table: result
--
CREATE TABLE result (
  id INTEGER PRIMARY KEY NOT NULL,
  job_handle varchar(255),
  unique_token varchar(60) NOT NULL,
  session varchar(100),
  user integer DEFAULT null,
  name varchar(120),
  input_type varchar(20) NOT NULL DEFAULT 'txt',
  output_type varchar(20) NOT NULL DEFAULT 'treex',
  language integer,
  last_modified datetime NOT NULL,
  FOREIGN KEY (language) REFERENCES languages(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);
CREATE INDEX result_idx_language ON result (language);
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
  sample text,
  public boolean NOT NULL,
  user integer NOT NULL DEFAULT 0,
  created_at datetime NOT NULL,
  last_modified datetime NOT NULL,
  FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);
CREATE INDEX scenarios_idx_user ON scenarios (user);
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
COMMIT;
