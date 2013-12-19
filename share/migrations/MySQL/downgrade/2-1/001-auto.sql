-- Convert schema '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/2/001-auto.yml' to '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/1/001-auto.yml':;

;
BEGIN;

ALTER TABLE user ADD COLUMN name varchar(120) NULL;
;
UPDATE user name=TRIM(CONCAT(first_name, last_name));
;
DELETE FROM user WHERE password IS NULL or email is NULL;
;
ALTER TABLE user DROP INDEX token_unique,
                 DROP COLUMN persistent_token,
                 DROP COLUMN organization,
                 DROP COLUMN first_name,
                 DROP COLUMN last_name,
                 ADD COLUMN name varchar(120) NULL,
                 CHANGE COLUMN email email varchar(120) NOT NULL,
                 CHANGE COLUMN password password char(59) NOT NULL,
                 ADD UNIQUE email_unique (email);

;

COMMIT;

