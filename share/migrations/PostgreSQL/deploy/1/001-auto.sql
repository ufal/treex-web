-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Mon Jan 28 23:50:03 2013
-- 
;
--
-- Table: result
--
CREATE TABLE "result" (
  "id" serial NOT NULL,
  "job_uid" character varying(60) NOT NULL,
  "session" character varying(100) NOT NULL,
  "user" integer DEFAULT null,
  "name" character varying(120),
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "hash_unique" UNIQUE ("job_uid")
);
CREATE INDEX "result_idx_user" on "result" ("user");

;
--
-- Table: scenario
--
CREATE TABLE "scenario" (
  "id" serial NOT NULL,
  "scenario" text NOT NULL,
  "name" character varying(120) NOT NULL,
  "comment" text,
  "public" boolean NOT NULL,
  "user" integer DEFAULT 0 NOT NULL,
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "name_user_unique" UNIQUE ("name", "user")
);
CREATE INDEX "scenario_idx_user" on "scenario" ("user");

;
--
-- Table: user
--
CREATE TABLE "user" (
  "id" serial NOT NULL,
  "email" character varying(120) NOT NULL,
  "password" character(59) NOT NULL,
  "active" boolean NOT NULL,
  "activate_token" character(20),
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "email_unique" UNIQUE ("email")
);

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "result" ADD CONSTRAINT "result_fk_user" FOREIGN KEY ("user")
  REFERENCES "user" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "scenario" ADD CONSTRAINT "scenario_fk_user" FOREIGN KEY ("user")
  REFERENCES "user" ("id") ON DELETE CASCADE DEFERRABLE;

