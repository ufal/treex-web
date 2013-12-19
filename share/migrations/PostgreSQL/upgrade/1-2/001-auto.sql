-- Convert schema '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/1/001-auto.yml' to '/home/thc/work/treex-web/bin/../share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user DROP CONSTRAINT email_unique;

;
ALTER TABLE user DROP COLUMN name;

;
ALTER TABLE user ADD COLUMN persistent_token character varying(120);

;
ALTER TABLE user ADD COLUMN organization character varying(120);

;
UPDATE user persistent_token=email, organization='local', first_name=name;

;
ALTER TABLE user ADD COLUMN first_name character varying(120);

;
ALTER TABLE user ADD COLUMN last_name character varying(120);

;
ALTER TABLE user ALTER COLUMN persistent_token SET NOT NULL;

;
ALTER TABLE user ALTER COLUMN organization SET NOT NULL;

;
ALTER TABLE user ALTER COLUMN email DROP NOT NULL;

;
ALTER TABLE user ALTER COLUMN password DROP NOT NULL;

;
ALTER TABLE user ADD CONSTRAINT token_unique UNIQUE (persistent_token);

;

COMMIT;

