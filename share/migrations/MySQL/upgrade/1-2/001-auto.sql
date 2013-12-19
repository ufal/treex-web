-- Convert schema '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/1/001-auto.yml' to '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

ALTER TABLE user ADD COLUMN persistent_token varchar(120) NULL,
                 ADD COLUMN organization varchar(120) NULL,
                 ADD COLUMN first_name varchar(120) NULL,
                 ADD COLUMN last_name varchar(120) NULL;
;
UPDATE user persistent_token=email, organization='local', first_name=name;
;
ALTER TABLE user DROP INDEX email_unique,
                 DROP COLUMN name,
                 CHANGE COLUMN persistent_token persistent_token varchar(120) NOT NULL,
                 CHANGE COLUMN organization organization varchar(120) NOT NULL,
                 CHANGE COLUMN email email varchar(120) NULL,
                 CHANGE COLUMN password password char(59) NULL,
                 ADD UNIQUE token_unique (persistent_token);

;

COMMIT;

