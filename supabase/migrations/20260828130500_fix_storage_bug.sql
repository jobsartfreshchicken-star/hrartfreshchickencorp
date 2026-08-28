-- Fixes a bug where "Add Employee", "Add Violation", and case file attachments
-- silently failed to persist across a page reload (the page called a
-- window.storage API that was never actually defined anywhere).
-- Everything now goes through Supabase instead. Safe to run more than once.

-- Case attachments now live directly on the case row instead of a separate,
-- never-working key-value store.
alter table disciplinary_cases
  add column if not exists attachments jsonb;

-- Safety net in case this table doesn't already exist -- ensureEmployeeSynced()
-- in index.html has been upserting into it since before this migration, so it
-- likely already exists with this shape; IF NOT EXISTS makes this a no-op then.
create table if not exists employees (
  id text primary key,
  name text,
  department text,
  position text,
  status text,
  date_hired date,
  created_at timestamptz default now()
);

-- Holds violations added through "Add Violation" or the Excel importer on the
-- Violation Reference tab (the 91 built-in offenses stay in index.html itself).
create table if not exists custom_violations (
  id text primary key,
  category text,
  name text,
  description text,
  severity text,
  action text,
  created_at timestamptz default now()
);
