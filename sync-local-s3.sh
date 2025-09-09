#!/bin/bash
# Synchronize a local directory to an S3 bucket.
# New files in the local directory will be uploaded to the S3 bucket.
# Files deleted from the local directory will be deleted from the S3 bucket.
# Existing files in the S3 bucket that are not in the local directory will be deleted.

# For example:
#   sync-local-s3.sh C:\Users\evanchu\Documents s3://S3BucketName/Documents

SrcDir="$1"
S3Url="$2"

if [ -z "$SrcDir" ]; then
  echo "Source directory is not specified"
  exit 1
fi

if [ ! -d "$SrcDir" ]; then
  echo "${SrcDir} directory does not exist"
  exit 1
fi

if [ -z "$S3Url" ]; then
  echo "S3 URL is not specified"
  exit 1
fi

# Parse the S3 bucket name from the S3 URL such as s3://S3BucketName/Path.
S3BucketName=$(echo $S3Url | cut -d '/' -f 3)

# Check AWS credentials.
aws sts get-caller-identity
# Check the exit status of the previous command.
if [ $? -ne 0 ]; then
  echo "Failed to verify AWS credentials"
  exit 1
fi

# Check if the S3 bucket exists.
aws s3api head-bucket --bucket "${S3BucketName}"
# Check the exit status of the previous command.
if [ $? -ne 0 ]; then
  echo "S3 bucket ${S3BucketName} does not exist or you do not have access"
  exit 1
fi

Param="--delete"
echo "Press ENTER to synchronize ${SrcDir} to ${S3Url} with parameter ${Param}"
read
set -x # Enable command echo for debugging.
aws s3 sync $SrcDir $S3Url $Param
aws s3 ls $S3Url --summarize --human-readable --recursive | tail -n 10
