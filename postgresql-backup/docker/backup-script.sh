#!/bin/bash
# Environment variables: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, POSTGRES_HOST, AWS_S3_BUCKET
pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB > db_backup.sql
aws s3 cp db_backup.sql s3://$AWS_S3_BUCKET/$(date +%Y-%m-%d_%H-%M-%S)_db_backup.sql
