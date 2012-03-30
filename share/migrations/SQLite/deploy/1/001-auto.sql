-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Mar 30 15:27:28 2012
-- 

;
BEGIN TRANSACTION;
--
-- Table: result
--
CREATE TABLE result (
  id INTEGER PRIMARY KEY NOT NULL,
  result_hash varchar(60) NOT NULL,
  user integer DEFAULT null,
  name varchar(120),
  scenario text NOT NULL,
  stdin varchar(200) NOT NULL,
  cmd text NOT NULL,
  stdout varchar(200) NOT NULL,
  stderr varchar(200) NOT NULL,
  ret integer NOT NULL DEFAULT 1,
  last_modified datetime NOT NULL,
  FOREIGN KEY(user) REFERENCES user(id)
);
CREATE INDEX result_idx_user ON result (user);
CREATE UNIQUE INDEX hash_unique ON result (result_hash);
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
  FOREIGN KEY(user) REFERENCES user(id)
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