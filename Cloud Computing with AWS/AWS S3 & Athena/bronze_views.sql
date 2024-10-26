DROP DATABASE IF EXISTS arbash_malik_homework;
CREATE DATABASE IF NOT EXISTS arbash_malik_homework;

DROP TABLE IF EXISTS arbash_malik_homework.bronze_views;
CREATE EXTERNAL TABLE arbash_malik_homework.bronze_views (
    article STRING,
    views INT,
    rank INT,
    date DATE,
    retrieved_at TIMESTAMP) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://ceu-arbash-de2-hw4/datalake/views/';
