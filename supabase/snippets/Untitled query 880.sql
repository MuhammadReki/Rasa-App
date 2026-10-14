-- Ambil user ID pertama
-- (ganti <USER_ID> dengan ID dari tabel profiles)

insert into public.articles (author_id, title, content, preview, cover_url, tag, status)
values
  (
    (select id from public.profiles limit 1),
    'Kita tidak harus kuat setiap hari',
    'Ada masa ketika semua orang berkata, "kamu kuat, kok." Dan aku mengangguk, seolah kalimat itu sebuah selimut hangat yang bisa kupakai sepanjang hari.

Padahal, kuat bukan selalu tentang bertahan. Kadang ia adalah keberanian untuk berdiam sebentar, lalu mengakui bahwa kita lelah.

"Kita tidak perlu menjadi versi paling kuat dari diri kita untuk tetap layak dicintai."

Aku belajar memberi ruang pada hari-hari yang tidak rapi. Membuat teh, membuka jendela, dan membiarkan hati bernapas tanpa harus menjelaskan apa-apa.',
    'Tentang hari-hari ketika pulang adalah satu-satunya hal yang ingin aku lakukan.',
    'https://images.pexels.com/photos/13735945/pexels-photo-13735945.jpeg?auto=compress&cs=tinysrgb&w=800',
    '#relationship',
    'published'
  ),
  (
    (select id from public.profiles limit 1),
    'Ritual kecil untuk mencintai diri sendiri',
    'Aku mulai merawat pagi yang sederhana, lalu perlahan merawat diriku.',
    'Aku mulai merawat pagi yang sederhana, lalu perlahan merawat diriku.',
    'https://images.pexels.com/photos/8924253/pexels-photo-8924253.jpeg?auto=compress&cs=tinysrgb&w=800',
    '#selflove',
    'published'
  ),
  (
    (select id from public.profiles limit 1),
    'Pelan-pelan, aku belajar pulang pada diriku sendiri',
    'Sebuah catatan kecil tentang keberanian untuk memilih diri sendiri, setelah terlalu lama mengalah.',
    'Sebuah catatan kecil tentang keberanian untuk memilih diri sendiri.',
    'https://images.pexels.com/photos/5426883/pexels-photo-5426883.jpeg?auto=compress&cs=tinysrgb&w=800',
    '#selflove',
    'published'
  ),
  (
    (select id from public.profiles limit 1),
    'Kopi hangat dan jeda yang kupilih',
    'Tentang hari-hari yang tidak rapi dan mengapa itu tidak apa-apa.',
    'Tentang hari-hari yang tidak rapi dan mengapa itu tidak apa-apa.',
    'https://images.pexels.com/photos/6788788/pexels-photo-6788788.jpeg?auto=compress&cs=tinysrgb&w=800',
    '#random',
    'published'
  );