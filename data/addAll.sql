\echo -> Processing: 1 of 10
\i price_41fce2bf.sql
\echo -> Processing: 2 of 10
\i price_428de7f6.sql
\echo -> Processing: 3 of 10
\i price_4cde7b77.sql
\echo -> Processing: 4 of 10
\i price_559d0525.sql
\echo -> Processing: 5 of 10
\i price_59b0bcf9.sql
\echo -> Processing: 6 of 10
\i price_66d809d3.sql
\echo -> Processing: 7 of 10
\i price_6df3a970.sql
\echo -> Processing: 8 of 10
\i price_923532b1.sql
\echo -> Processing: 9 of 10
\i price_e1a8a029.sql
\echo -> Processing: 10 of 10
\i price_f6491a81.sql

-- improve the speed of lookups
CREATE INDEX idx_price_index_history_date on price_index_history(date);