-- Cek apakah kolom parent_id ada
select column_name, data_type 
from information_schema.columns 
where table_name = 'comments' 
  and column_name = 'parent_id';