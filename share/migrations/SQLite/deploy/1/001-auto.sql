-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Jan 29 15:38:35 2013
-- 

;
BEGIN TRANSACTION;
--
-- Table: result
--
CREATE TABLE result (
  id INTEGER PRIMARY KEY NOT NULL,
  job_id integer,
  unique_token varchar(60) NOT NULL,
  session varchar(100) NOT NULL,
  user integer DEFAULT null,
  name varchar(120),
  last_modified datetime NOT NULL,
  FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);
CREATE INDEX result_idx_user ON result (user);
CREATE UNIQUE INDEX unique_token ON result (unique_token);
--
-- Table: scenario
--
CREATE TABLE scenario (
  id INTEGER PRIMARY KEY NOT NULL,
  scenario text NOT NULL,
  name varchar(120) NOT NULL,
  comment text,
  public boolean NOT NULL,
  user integer NOT NULL DEFAULT 0,
  last_modified datetime NOT NULL,
  FOREIGN KEY (user) REFERENCES user(id) ON DELETE CASCADE
);
CREATE INDEX scenario_idx_user ON scenario (user);
CREATE UNIQUE INDEX name_user_unique ON scenario (name, user);
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
COMMIT