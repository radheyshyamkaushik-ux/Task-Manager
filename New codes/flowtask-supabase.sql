create extension if not exists pgcrypto;

create table if not exists public.flowtask_workspaces (
  id uuid primary key,
  title text not null default 'FlowTask workspace',
  data jsonb not null default '{}'::jsonb,
  updated_by text,
  updated_at timestamptz not null default now()
);

alter table public.flowtask_workspaces enable row level security;

drop policy if exists "FlowTask shared read" on public.flowtask_workspaces;
drop policy if exists "FlowTask shared insert" on public.flowtask_workspaces;
drop policy if exists "FlowTask shared update" on public.flowtask_workspaces;

create policy "FlowTask shared read"
on public.flowtask_workspaces
for select
to anon, authenticated
using (true);

create policy "FlowTask shared insert"
on public.flowtask_workspaces
for insert
to anon, authenticated
with check (true);

create policy "FlowTask shared update"
on public.flowtask_workspaces
for update
to anon, authenticated
using (true)
with check (true);

create or replace function public.touch_flowtask_workspace()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists touch_flowtask_workspace on public.flowtask_workspaces;
create trigger touch_flowtask_workspace
before update on public.flowtask_workspaces
for each row execute function public.touch_flowtask_workspace();

do $$
begin
  alter publication supabase_realtime add table public.flowtask_workspaces;
exception
  when duplicate_object then null;
end $$;
