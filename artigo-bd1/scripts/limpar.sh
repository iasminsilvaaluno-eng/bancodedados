#!/bin/bash
psql -U postgres -d tpch <<'SQL'
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT indexname FROM pg_indexes WHERE schemaname='public' LOOP
    EXECUTE 'DROP INDEX public.' || quote_ident(r.indexname);
  END LOOP;
END $$;
ANALYZE;
SQL
