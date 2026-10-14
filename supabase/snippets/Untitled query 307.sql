-- Artikel 2
with author as (select id from public.profiles limit 1)
insert into public.articles (author_id, title, content, preview, cover_url, tag, status)
select author.id,
  'Ritual kecil untuk mencintai diri sendiri',
  'Aku mulai merawat pagi yang sederhana, lalu perlahan merawat diriku.
Ada waktu untuk menulis, ada waktu untuk diam.
Pelan-pelan, aku belajar bahwa mencintai diri bukan soal besar.',
  'Aku mulai merawat pagi yang sederhana, lalu perlahan merawat diriku.',
  'https://images.pexels.com/photos/8924253/pexels-photo-8924253.jpeg?auto=compress&cs=tinysrgb&w=800',
  '#selflove', 'published'
from author;

-- Artikel 3
with author as (select id from public.profiles limit 1)
insert into public.articles (author_id, title, content, preview, cover_url, tag, status)
select author.id,
  'Pelan-pelan, aku belajar pulang pada diriku sendiri',
  'Sebuah catatan kecil tentang keberanian untuk memilih diri sendiri, setelah terlalu lama mengalah.
Hari ini aku memilih untuk diam sejenak. Bukan menyerah, tapi mengumpulkan tenaga.',
  'Sebuah catatan kecil tentang keberanian untuk memilih diri sendiri.',
  'https://images.pexels.com/photos/5426883/pexels-photo-5426883.jpeg?auto=compress&cs=tinysrgb&w=800',
  '#selflove', 'published'
from author;

-- Artikel 4
with author as (select id from public.profiles limit 1)
insert into public.articles (author_id, title, content, preview, cover_url, tag, status)
select author.id,
  'Kopi hangat dan jeda yang kupilih',
  'Tentang hari-hari yang tidak rapi dan mengapa itu tidak apa-apa.
Kopi panas di tangan, hujan di luar jendela, dan aku memilih untuk tidak buru-buru hari ini.',
  'Tentang hari-hari yang tidak rapi dan mengapa itu tidak apa-apa.',
  'https://images.pexels.com/photos/6788788/pexels-photo-6788788.jpeg?auto=compress&cs=tinysrgb&w=800',
  '#random', 'published'
from author;