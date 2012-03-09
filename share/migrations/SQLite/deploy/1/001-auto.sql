-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Mar  9 13:08:07 2012
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
  email text NOT NULL,
  password text NOT NULL,
  last_modified datetime NOT NULL
);
CREATE UNIQUE INDEX email_unique ON user (email);
COMMIT