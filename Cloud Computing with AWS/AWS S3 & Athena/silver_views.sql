DROP TABLE IF EXISTS arbash_malik_homework.silver_views;
CREATE TABLE IF NOT EXISTS arbash_malik_homework.silver_views
WITH (
      format = 'PARQUET',
      parquet_compression = 'SNAPPY',
      external_location = 's3://ceu-arbash-de2-hw4/datalake/views_silver/'
) AS SELECT article, views, rank, date FROM arbash_malik_homework.bronze_views;
