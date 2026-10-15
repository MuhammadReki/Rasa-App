-- Drop policy comment_bookmarks
drop policy if exists "Users can view own comment bookmarks" on public.comment_bookmarks;
drop policy if exists "Users can insert own comment bookmarks" on public.comment_bookmarks;
drop policy if exists "Users can delete own comment bookmarks" on public.comment_bookmarks;

-- Drop policy reports
drop policy if exists "Users can insert own reports" on public.reports;
drop policy if exists "Users can view own reports" on public.reports;

-- Drop policy blocks
drop policy if exists "Users can view own blocks" on public.blocks;
drop policy if exists "Users can insert own blocks" on public.blocks;
drop policy if exists "Users can delete own blocks" on public.blocks;