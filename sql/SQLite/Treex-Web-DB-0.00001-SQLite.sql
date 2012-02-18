-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat Feb 18 00:46:05 2012
-- 

BEGIN TRANSACTION;

--
-- Table: result
--
DROP TABLE result;

CREATE TABLE result (
  id INTEGER PRIMARY KEY NOT NULL,
  hash varchar(30) NOT NULL,
  user integer DEFAULT null,
  name varchar(120) NOT NULL,
  scenario text NOT NULL,
  last_modified datetime NOT NULL,
  FOREIGN KEY(user) REFERENCES user(id)
);

CREATE INDEX result_idx_user ON result (user);

CREATE UNIQUE INDEX hash_unique ON result (hash);

--
-- Table: user
--
DROP TABLE user;

CREATE TABLE user (
  id INTEGER PRIMARY KEY NOT NULL,
  email varchar(120) NOT NULL,
  password varchar(120) NOT NULL,
  last_modified datetime NOT NULL
);

CREATE UNIQUE INDEX email_unique ON user (email);

COMMIT;
