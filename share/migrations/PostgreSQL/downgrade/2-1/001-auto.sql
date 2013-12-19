-- Convert schema '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/2/001-auto.yml' to '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/1/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user DROP CONSTRAINT token_unique;

;
ALTER TABLE user DROP COLUMN persistent_token;

;
ALTER TABLE user DROP COLUMN organization;

;
ALTER TABLE user DROP COLUMN first_name;

;
ALTER TABLE user DROP COLUMN last_name;

;
DELETE FROM user WHERE password IS NULL or email is NULL;

;
ALTER TABLE user ADD COLUMN name character varying(120);

;
ALTER TABLE user ALTER COLUMN email SET NOT NULL;

;
ALTER TABLE user ALTER COLUMN password SET NOT NULL;

;
ALTER TABLE user ADD CONSTRAINT email_unique UNIQUE (email);

;

COMMIT;

