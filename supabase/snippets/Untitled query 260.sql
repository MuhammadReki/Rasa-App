-- Lihat user & role
select id, full_name, username, role from public.profiles;

-- Set user lo jadi admin (ganti email dengan email lo)
update public.profiles
set role = 'admin'
where id = (
  select id from auth.users where email = 'aluna@rasa.app'
);

-- Verifikasi
select id, full_name, username, role from public.profiles where role = 'admin';