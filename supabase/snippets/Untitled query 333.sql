-- Ambil user ID pertama
with author as (
  select id from public.profiles limit 1
)
insert into public.articles (author_id, title, content, preview, cover_url, tag, status)
select
  author.id,
  'Kita tidak harus kuat setiap hari',
  'Ada masa ketika semua orang berkata, "kamu kuat, kok." Dan aku mengangguk, seolah kalimat itu sebuah selimut hangat yang bisa kupakai sepanjang hari.

Padahal, kuat bukan selalu tentang bertahan. Kadang ia adalah keberanian untuk berdiam sebentar, lalu mengakui bahwa kita lelah.

"Kita tidak perlu menjadi versi paling kuat dari diri kita untuk tetap layak dicintai."

Aku belajar memberi ruang pada hari-hari yang tidak rapi. Membuat teh, membuka jendela, dan membiarkan hati bernapas tanpa harus menjelaskan apa-apa.',
  'Tentang hari-hari ketika pulang adalah satu-satunya hal yang ingin aku lakukan.',
  'https://images.pexels.com/photos/13735945/pexels-photo-13735945.jpeg?auto=compress&cs=tinysrgb&w=800',
  '#relationship',
  'published'
from author;