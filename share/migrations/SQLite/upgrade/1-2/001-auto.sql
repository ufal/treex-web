-- Convert schema '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/1/001-auto.yml' to '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE user_temp_alter (
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

;
INSERT INTO user_temp_alter(id, persistent_token, organization, first_name, email, password, is_admin, active, activate_token, last_modified)
SELECT id, email, 'local', name, email, password, is_admin, active, activate_token, last_modified
FROM user;

;
DROP TABLE user;

;
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

;
CREATE UNIQUE INDEX token_unique ON user (persistent_token);

;
INSERT INTO user SELECT id, persistent_token, organization, first_name, last_name, email, password, is_admin, active, activate_token, last_modified FROM user_temp_alter;

;
DROP TABLE user_temp_alter;

;

COMMIT;

