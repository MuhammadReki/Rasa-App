create or replace function increment_view_count(article_id uuid)
returns void as $$
begin
  update public.articles
  set view_count = view_count + 1
  where id = article_id;
end;
$$ language plpgsql security definer;