-- Policy: admin bisa update semua artikel
drop policy if exists "Admins can update all articles" on public.articles;
create policy "Admins can update all articles"
  on public.articles for update
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Policy: admin bisa delete semua artikel
drop policy if exists "Admins can delete all articles" on public.articles;
create policy "Admins can delete all articles"
  on public.articles for delete
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Policy: admin bisa liat semua artikel (semua status)
drop policy if exists "Admins can view all articles" on public.articles;
create policy "Admins can view all articles"
  on public.articles for select
  using (
    status = 'published'
    or auth.uid() = author_id
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );