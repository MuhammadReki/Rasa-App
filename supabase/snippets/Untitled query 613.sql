create table if not exists public.comment_bookmarks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  comment_id uuid references public.comments(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, comment_id)
);

alter table public.comment_bookmarks enable row level security;

create policy "Users can view own comment bookmarks"
  on public.comment_bookmarks for select using (auth.uid() = user_id);

create policy "Users can insert own comment bookmarks"
  on public.comment_bookmarks for insert with check (auth.uid() = user_id);

create policy "Users can delete own comment bookmarks"
  on public.comment_bookmarks for delete using (auth.uid() = user_id);