#!/bin/bash
set -e

# Load Options
while getopts "a:b:c:d:e:f:" o; do
   case "${o}" in
       a)
         export REPO=${OPTARG}
       ;;
       b)
         export REF=${OPTARG}
       ;;
       c)
         export FILE=${OPTARG}
       ;;
       d)
         export FILE_PATH=${OPTARG}
       ;;
       e)
         export EXE_ARGS=${OPTARG}
       ;;
       f)
         export FAIL_ON_NON_ZERO=${OPTARG}
       ;;
  esac
done

# Get Artifact URL
if [ $REF == "latest" ]; then
    echo "Identifying latest release..."
    RELEASE_REQ_URL="https://api.github.com/repos/$REPO/releases/latest"
    FILE_URL=$(curl -s -H "Accept: application/vnd.github.v3+json" $RELEASE_REQ_URL | jq -r ".assets[] | select(.name==\"$FILE\") | .browser_download_url")

    if [ -z "$FILE_URL" ]; then
        echo "Not Found"
        exit 1
    fi
else
    FILE_URL="https://github.com/$REPO/releases/download/$REF/$FILE"
fi

# Download Artifact (s = silent, L = follow redirects, o = output path)
echo "Downloading artifact..."
STATUS_CODE=$(curl -sL -w '%{http_code}' -o "$FILE" "$FILE_URL")

if [ "$STATUS_CODE" != "200" ]; then
    echo "Failed to download: $STATUS_CODE"
    exit 1
fi

# Unzip File (qq = quiet, o = overwrite)
echo "Unzipping file..."
unzip -qqo "$FILE"

# Validate File
if [ ! -f "$FILE_PATH" ]; then
    echo "File did not exist in zip: $FILE_PATH"
    exit 1
fi

if [ ! -x "$FILE_PATH" ]; then
    echo "File is not executable: $FILE_PATH"
    exit 1
fi

# Call Executable
echo "Running command..."
OUTPUT=$($FILE_PATH $EXE_ARGS)
OUTPUT_CODE=$?

# Set Outputs
echo "Setting outputs..."
echo "::set-output name=exitCode::$OUTPUT_CODE"

OUTPUT="${OUTPUT//'%'/'%25'}"
OUTPUT="${OUTPUT//$'\n'/'%0A'}"
OUTPUT="${OUTPUT//$'\r'/'%0D'}"
echo "::set-output name=commandOutput::$OUTPUT"

if [ "$OUTPUT_CODE" != "0" ] && [ "$FAIL_ON_NON_ZERO" == "true" ]; then
    echo "Unexpected exit code: $OUTPUT_CODE"
    exit $OUTPUT_CODE
fi