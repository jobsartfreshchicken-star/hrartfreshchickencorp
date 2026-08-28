-- Adds the fields needed by the Violation / Disciplinary Case Tracker
-- (classification, notice-served, admin hearing, and case-closing details)
-- to the existing disciplinary_cases table. Safe to run more than once.

alter table disciplinary_cases
  add column if not exists classification text,

  add column if not exists notice_date date,
  add column if not exists response_period text,
  add column if not exists serve_mode text,
  add column if not exists serve_remarks text,

  add column if not exists hearing_held text,
  add column if not exists hearing_venue text,
  add column if not exists hearing_datetime timestamptz,
  add column if not exists hearing_proof jsonb,

  add column if not exists decision text,
  add column if not exists verbal_followup_date date,
  add column if not exists written_issued_date date,
  add column if not exists written_attachment jsonb,

  add column if not exists date_closed date,
  add column if not exists closing_remarks text;
