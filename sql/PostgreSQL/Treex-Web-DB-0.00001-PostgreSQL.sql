-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sat Feb 18 00:46:05 2012
-- 
--
-- Table: result
--
DROP TABLE "result" CASCADE;
CREATE TABLE "result" (
  "id" serial NOT NULL,
  "hash" character varying(30) NOT NULL,
  "user" integer DEFAULT null,
  "name" character varying(120) NOT NULL,
  "scenario" text NOT NULL,
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "hash_unique" UNIQUE ("hash")
);
CREATE INDEX "result_idx_user" on "result" ("user");

--
-- Table: user
--
DROP TABLE "user" CASCADE;
CREATE TABLE "user" (
  "id" serial NOT NULL,
  "email" character varying(120) NOT NULL,
  "password" character varying(120) NOT NULL,
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "email_unique" UNIQUE ("email")
);

--
-- Foreign Key Definitions
--

ALTER TABLE "result" ADD FOREIGN KEY ("user")
  REFERENCES "user" ("id") ON DELETE CASCADE DEFERRABLE;

