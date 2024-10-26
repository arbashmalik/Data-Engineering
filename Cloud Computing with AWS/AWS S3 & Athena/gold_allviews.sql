DROP TABLE IF EXISTS arbash_malik_homework.gold_allviews;
CREATE TABLE IF NOT EXISTS arbash_malik_homework.gold_allviews
WITH (
      format = 'PARQUET',
      parquet_compression = 'SNAPPY',
      external_location = 's3://ceu-arbash-de2-hw4/datalake/gold_allviews/'
) AS SELECT article, sum(views) as total_top_views, min(rank) as top_rank, COUNT(DISTINCT date) as ranked_days FROM arbash_malik_homework.silver_views group by 1;
    
