#!/bin/bash
set -eo pipefail

export AWS_S3_BACKUP_FILE_PATH=$1

echo

if [ ! -f "$AWS_SHARED_CREDENTIALS_FILE" ]; then
  echo "AWS-S3: No credentials configured for AWS S3 - skipping backup publication."
  exit 0
fi

if [ -z "$AWS_S3_BACKUP_FILE_PATH" ]; then
  echo "AWS-S3: You have to pass backup file path as first parameter for this script."
  exit 1
fi

if [ -z "$AWS_S3_BUCKET_NAME" ]; then
  echo "AWS-S3: You have to pass AWS S3 bucket name in 'AWS_S3_BUCKET_NAME' variable."
  exit 1
fi

if [ -z "$AWS_S3_SSE_CUSTOMER_KEY" ]; then
  echo "AWS-S3: You have to pass SSE Customer Key for client side encryption as 'AWS_S3_SSE_CUSTOMER_KEY' variable."
  exit 1
fi

echo "AWS-S3: Publishing backup $AWS_S3_BACKUP_FILE_PATH to s3://$AWS_S3_BUCKET_NAME"

echo "aws s3 cp --sse-c AES256 --sse-c-key fileb://$AWS_S3_SSE_CUSTOMER_KEY $AWS_S3_BACKUP_FILE_PATH s3://$AWS_S3_BUCKET_NAME"
aws s3 cp --sse-c AES256 --sse-c-key "fileb://$AWS_S3_SSE_CUSTOMER_KEY" "$AWS_S3_BACKUP_FILE_PATH" "s3://$AWS_S3_BUCKET_NAME"
PUBLICATION_RESULT=$?

echo
echo "AWS-S3: List of all published backups at s3://$AWS_S3_BUCKET_NAME"
aws s3 ls "s3://$AWS_S3_BUCKET_NAME"

echo
if [ $PUBLICATION_RESULT -eq 0 ]; then
  echo "AWS-S3: Publishing backup - DONE $AWS_S3_BACKUP_FILE_PATH to s3://$AWS_S3_BUCKET_NAME"
  echo
  exit 0
else
  echo "AWS-S3: Publishing backup - FAILED $AWS_S3_BACKUP_FILE_PATH to s3://$AWS_S3_BUCKET_NAME"
  echo
  exit 1
fi
