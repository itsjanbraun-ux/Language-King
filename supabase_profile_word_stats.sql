-- Language King: device-crossing learn progress
-- Run this in Supabase SQL editor before using synced flashcard stats.

create table if not exists public.profile_word_stats (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete cascade,
  language text not null check (language in ('latin', 'english')),
  foreign_word text not null,
  correct_count int not null default 0,
  wrong_count int not null default 0,
  last_seen timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(profile_id, language, foreign_word)
);

create index if not exists profile_word_stats_profile_idx
  on public.profile_word_stats(profile_id, language);

alter table public.profile_word_stats enable row level security;

create policy "profile_word_stats_select_own"
  on public.profile_word_stats for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.user_id = auth.uid()
    )
  );

create policy "profile_word_stats_insert_own"
  on public.profile_word_stats for insert
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.user_id = auth.uid()
    )
  );

create policy "profile_word_stats_update_own"
  on public.profile_word_stats for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.user_id = auth.uid()
    )
  );

create policy "profile_word_stats_delete_own"
  on public.profile_word_stats for delete
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.user_id = auth.uid()
    )
  );
