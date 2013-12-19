-- Convert schema '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/2/001-auto.yml' to '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/1/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE user_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  email varchar(120),
  name varchar(120),
  password char(59),
  is_admin boolean NOT NULL,
  active boolean NOT NULL,
  activate_token char(20),
  last_modified datetime NOT NULL
);

;
INSERT INTO user_temp_alter (id, email, password, is_admin, active, activate_token, last_modified)
SELECT id, email, password, is_admin, active, activate_token, last_modified)
FROM user;
;
DELETE FROM user WHERE email IS NULL OR password IS NULL;
;
DROP TABLE user;

;
CREATE TABLE user (
  id INTEGER PRIMARY KEY NOT NULL,
  email varchar(120) NOT NULL,
  name varchar(120),
  password char(59) NOT NULL,
  is_admin boolean NOT NULL,
  active boolean NOT NULL,
  activate_token char(20),
  last_modified datetime NOT NULL
);

;
CREATE UNIQUE INDEX email_unique ON user (email);

;
INSERT INTO user SELECT id, email, name, password, is_admin, active, activate_token, last_modified FROM user_temp_alter;

;
DROP TABLE user_temp_alter;

;

COMMIT;

