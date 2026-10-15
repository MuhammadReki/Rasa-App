-- ===================
-- BOOKMARK KOMENTAR
-- ===================
create table if not exists public.comment_bookmarks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  comment_id uuid references public.comments(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, comment_id)
);

alter table public.comment_bookmarks enable row level security;

drop policy if exists "Users can view own comment bookmarks" on public.comment_bookmarks;
drop policy if exists "Users can insert own comment bookmarks" on public.comment_bookmarks;
drop policy if exists "Users can delete own comment bookmarks" on public.comment_bookmarks;

create policy "Users can view own comment bookmarks"
  on public.comment_bookmarks for select using (auth.uid() = user_id);

create policy "Users can insert own comment bookmarks"
  on public.comment_bookmarks for insert with check (auth.uid() = user_id);

create policy "Users can delete own comment bookmarks"
  on public.comment_bookmarks for delete using (auth.uid() = user_id);

-- ===================
-- REPORTS
-- ===================
create table if not exists public.reports (
  id uuid default gen_random_uuid() primary key,
  reporter_id uuid references public.profiles(id) on delete cascade not null,
  article_id uuid references public.articles(id) on delete cascade,
  comment_id uuid references public.comments(id) on delete cascade,
  reason text not null,
  status text default 'pending' check (status in ('pending', 'reviewed', 'dismissed')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.reports enable row level security;

drop policy if exists "Users can insert own reports" on public.reports;
drop policy if exists "Users can view own reports" on public.reports;

create policy "Users can insert own reports"
  on public.reports for insert with check (auth.uid() = reporter_id);

create policy "Users can view own reports"
  on public.reports for select using (auth.uid() = reporter_id);

-- ===================
-- BLOCKS
-- ===================
create table if not exists public.blocks (
  id uuid default gen_random_uuid() primary key,
  blocker_id uuid references public.profiles(id) on delete cascade not null,
  blocked_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(blocker_id, blocked_id),
  check (blocker_id != blocked_id)
);

alter table public.blocks enable row level security;

drop policy if exists "Users can view own blocks" on public.blocks;
drop policy if exists "Users can insert own blocks" on public.blocks;
drop policy if exists "Users can delete own blocks" on public.blocks;

create policy "Users can view own blocks"
  on public.blocks for select using (auth.uid() = blocker_id);

create policy "Users can insert own blocks"
  on public.blocks for insert with check (auth.uid() = blocker_id);

create policy "Users can delete own blocks"
  on public.blocks for delete using (auth.uid() = blocker_id);