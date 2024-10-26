import datetime
import json
import os
from pathlib import Path
import boto3
import requests

start_date = datetime.datetime.strptime("2023-10-15", "%Y-%m-%d")
end_date = datetime.datetime.strptime("2023-10-21", "%Y-%m-%d")
date_range = [
    start_date + datetime.timedelta(days=x)
    for x in range((end_date - start_date).days + 1)
]

for date in date_range:
    DATE_PARAM = date.strftime("%Y-%m-%d")
    date = datetime.datetime.strptime(DATE_PARAM, "%Y-%m-%d")
    url = f"https://wikimedia.org/api/rest_v1/metrics/pageviews/top/en.wikipedia.org/all-access/{date.strftime('%Y/%m/%d')}"
    print(f"Requesting REST API URL: {url}")

    wiki_server_response = requests.get(url, headers={"User-Agent": "curl/7.68.0"})
    wiki_response_status = wiki_server_response.status_code
    wiki_response_body = wiki_server_response.text

    print(f"Wikipedia REST API Response body: {wiki_response_body}")
    print(f"Wikipedia REST API Response Code: {wiki_response_status}")

    if wiki_response_status != 200:
        print(
            f"Received non-OK status code from Wiki Server: {wiki_response_status}. Response body: {wiki_response_body}"
        )

    current_directory = Path(__file__).parent

    RAW_LOCATION_BASE = current_directory / "data" / "raw-views"

    RAW_LOCATION_BASE.mkdir(exist_ok=True, parents=True)
    print(f"Created directory {RAW_LOCATION_BASE}")

    raw_views_file = RAW_LOCATION_BASE / f"raw-views-{date.strftime('%Y-%m-%d')}.txt"
    with raw_views_file.open("w") as file:
        file.write(wiki_response_body)
        print(f"Saved raw views to {raw_views_file}")

    S3_WIKI_BUCKET = ""
    s3 = boto3.client("s3")
    S3_WIKI_BUCKET = "ceu-arbash-de2-hw4"

    bucket_names = [bucket["Name"] for bucket in s3.list_buckets()["Buckets"]]
    if S3_WIKI_BUCKET not in bucket_names:
        s3.create_bucket(
            Bucket=S3_WIKI_BUCKET,
            CreateBucketConfiguration={"LocationConstraint": "eu-west-1"},
        )

    assert S3_WIKI_BUCKET != "", "Please set the S3_WIKI_BUCKET variable"
    assert s3.list_objects(
        Bucket=S3_WIKI_BUCKET
    ), "The bucket {S3_WIKI_BUCKET} does not exist"

    res = s3.upload_file(
        raw_views_file,
        S3_WIKI_BUCKET,
        f"datalake/raw/raw-views-{date.strftime('%Y-%m-%d')}.txt",
    )
    print(
        f"Uploaded raw views to s3://{S3_WIKI_BUCKET}/datalake/raw/raw-views-{date.strftime('%Y-%m-%d')}.txt"
    )

    assert s3.head_object(
        Bucket=S3_WIKI_BUCKET,
        Key=f"datalake/raw/raw-views-{date.strftime('%Y-%m-%d')}.txt",
    )

    wiki_response_parsed = wiki_server_response.json()
    top_edits = wiki_response_parsed["items"][0]["articles"]

    current_time = datetime.datetime.utcnow()
    json_lines = ""
    for page in top_edits:
        record = {
            "article": page["article"],
            "views": page["views"],
            "rank": page["rank"],
            "date": date.strftime("%Y-%m-%d"),
            "retrieved_at": current_time.isoformat(),
        }
        json_lines += json.dumps(record) + "\n"

    JSON_LOCATION_DIR = current_directory / "data" / "views"
    JSON_LOCATION_DIR.mkdir(exist_ok=True, parents=True)
    print(f"Created directory {JSON_LOCATION_DIR}")
    print(f"JSON lines:\n{json_lines}")

    json_lines_filename = f"views-{date.strftime('%Y-%m-%d')}.json"
    json_lines_file = JSON_LOCATION_DIR / json_lines_filename

    with json_lines_file.open("w") as file:
        file.write(json_lines)

    s3.upload_file(
        json_lines_file, S3_WIKI_BUCKET, f"datalake/views/{json_lines_filename}"
    )
    print(
        f"Uploaded JSON lines to s3://{S3_WIKI_BUCKET}/datalake/views/{json_lines_filename}"
    )
