-- Recruitment: single-use QR/link application invites.
-- HR generates one invite per applicant (application_invites); the public
-- apply.html page looks it up by token and, on submit, calls
-- submit_application(...) which atomically marks the invite "submitted" and
-- stores the answers (applications). Because that flip happens inside one
-- database function instead of separate client-side reads/writes, two people
-- opening the same forwarded link can't both submit -- whichever call lands
-- first wins the race, the second gets rejected by the function itself.
-- Safe to run more than once.

create extension if not exists pgcrypto;

create table if not exists application_invites (
  id uuid primary key default gen_random_uuid(),
  token text unique not null,
  applicant_name text,
  position_applied text,
  department text,
  status text not null default 'pending', -- 'pending' | 'submitted'
  created_by text,
  created_at timestamptz default now(),
  used_at timestamptz
);

create table if not exists applications (
  id uuid primary key default gen_random_uuid(),
  invite_id uuid references application_invites(id),
  token text,
  data jsonb not null,
  submitted_at timestamptz default now()
);

-- The HR-side Recruitment tab needs to create invites and read everything
-- back; the public apply page needs to read invite status. Nobody -- not
-- even HR's own client code -- writes "submitted" or inserts into
-- applications directly; only submit_application() below does, so a forwarded
-- link can't be replayed by editing a request by hand.
grant select, insert on application_invites to anon, authenticated;
revoke update, delete on application_invites from anon, authenticated;

grant select on applications to anon, authenticated;
revoke insert, update, delete on applications from anon, authenticated;

create or replace function public.submit_application(p_token text, p_data jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite_id uuid;
  v_application_id uuid;
begin
  update application_invites
     set status = 'submitted', used_at = now()
   where token = p_token and status = 'pending'
   returning id into v_invite_id;

  if v_invite_id is null then
    raise exception 'invite_not_available';
  end if;

  insert into applications (invite_id, token, data)
  values (v_invite_id, p_token, p_data)
  returning id into v_application_id;

  return v_application_id;
end;
$$;

grant execute on function public.submit_application(text, jsonb) to anon, authenticated;
