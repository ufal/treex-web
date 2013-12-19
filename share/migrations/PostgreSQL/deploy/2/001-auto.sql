-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Dec 19 01:05:49 2013
-- 
;
--
-- Table: language_groups.
--
CREATE TABLE "language_groups" (
  "id" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "position" integer,
  PRIMARY KEY ("id")
);

;
--
-- Table: languages.
--
CREATE TABLE "languages" (
  "id" serial NOT NULL,
  "language_group" integer NOT NULL,
  "code" character varying(10) NOT NULL,
  "name" character varying(120) NOT NULL,
  "position" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "languages_idx_language_group" on "languages" ("language_group");

;
--
-- Table: user.
--
CREATE TABLE "user" (
  "id" serial NOT NULL,
  "persistent_token" character varying(120) NOT NULL,
  "organization" character varying(120) NOT NULL,
  "first_name" character varying(120),
  "last_name" character varying(120),
  "email" character varying(120),
  "password" character(59),
  "is_admin" boolean NOT NULL,
  "active" boolean NOT NULL,
  "activate_token" character(20),
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "token_unique" UNIQUE ("persistent_token")
);

;
--
-- Table: result.
--
CREATE TABLE "result" (
  "id" serial NOT NULL,
  "job_handle" character varying(255),
  "unique_token" character varying(60) NOT NULL,
  "session" character varying(100),
  "user" integer DEFAULT null,
  "name" character varying(120),
  "input_type" character varying(20) DEFAULT 'txt' NOT NULL,
  "output_type" character varying(20) DEFAULT 'treex' NOT NULL,
  "language" integer,
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_token" UNIQUE ("unique_token")
);
CREATE INDEX "result_idx_language" on "result" ("language");
CREATE INDEX "result_idx_user" on "result" ("user");

;
--
-- Table: scenarios.
--
CREATE TABLE "scenarios" (
  "id" serial NOT NULL,
  "scenario" text NOT NULL,
  "name" character varying(120) NOT NULL,
  "description" text,
  "sample" text,
  "public" boolean NOT NULL,
  "user" integer DEFAULT 0 NOT NULL,
  "created_at" timestamp NOT NULL,
  "last_modified" timestamp NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "scenarios_idx_user" on "scenarios" ("user");

;
--
-- Table: scenario_languages.
--
CREATE TABLE "scenario_languages" (
  "scenario" integer NOT NULL,
  "language" character varying NOT NULL,
  PRIMARY KEY ("scenario", "language")
);
CREATE INDEX "scenario_languages_idx_language" on "scenario_languages" ("language");
CREATE INDEX "scenario_languages_idx_scenario" on "scenario_languages" ("scenario");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "languages" ADD CONSTRAINT "languages_fk_language_group" FOREIGN KEY ("language_group")
  REFERENCES "language_groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "result" ADD CONSTRAINT "result_fk_language" FOREIGN KEY ("language")
  REFERENCES "languages" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "result" ADD CONSTRAINT "result_fk_user" FOREIGN KEY ("user")
  REFERENCES "user" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "scenarios" ADD CONSTRAINT "scenarios_fk_user" FOREIGN KEY ("user")
  REFERENCES "user" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "scenario_languages" ADD CONSTRAINT "scenario_languages_fk_language" FOREIGN KEY ("language")
  REFERENCES "languages" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "scenario_languages" ADD CONSTRAINT "scenario_languages_fk_scenario" FOREIGN KEY ("scenario")
  REFERENCES "scenarios" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
