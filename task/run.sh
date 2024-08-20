set -e

export SOURCE_URL='https://raw.githubusercontent.com/digital-land/'
export DATASET_DIR=dataset
export CACHE_DIR=var/cache

if [ -z "$DATA_PACKAGE_NAME" ]; then
    echo DATA_PACKAGE_NAME not set
    exit 1
fi

if [ "$DATA_PACKAGE_NAME" != 'organisation' ]; then
    echo Unspoorted package.
    exit 1
fi

TODAY=$(date +%Y-%m-%d)
echo "Running package builder for $DATA_PACKAGE_NAME on $TODAY"

echo Downloading specification
mkdir -p specification/
curl -qfsL $SOURCE_URL/specification/main/specification/attribution.csv > specification/attribution.csv
curl -qfsL $SOURCE_URL/specification/main/specification/licence.csv > specification/licence.csv
curl -qfsL $SOURCE_URL/specification/main/specification/typology.csv > specification/typology.csv
curl -qfsL $SOURCE_URL/specification/main/specification/theme.csv > specification/theme.csv
curl -qfsL $SOURCE_URL/specification/main/specification/collection.csv > specification/collection.csv
curl -qfsL $SOURCE_URL/specification/main/specification/dataset.csv > specification/dataset.csv
curl -qfsL $SOURCE_URL/specification/main/specification/dataset-field.csv > specification/dataset-field.csv
curl -qfsL $SOURCE_URL/specification/main/specification/field.csv > specification/field.csv
curl -qfsL $SOURCE_URL/specification/main/specification/datatype.csv > specification/datatype.csv
curl -qfsL $SOURCE_URL/specification/main/specification/prefix.csv > specification/prefix.csv
# deprecated ..
curl -qfsL $SOURCE_URL/specification/main/specification/pipeline.csv > specification/pipeline.csv
curl -qfsL $SOURCE_URL/specification/main/specification/dataset-schema.csv > specification/dataset-schema.csv
curl -qfsL $SOURCE_URL/specification/main/specification/schema.csv > specification/schema.csv
curl -qfsL $SOURCE_URL/specification/main/specification/schema-field.csv > specification/schema-field.csv
curl -qfsL $SOURCE_URL/specification/main/specification/datapackage.csv > specification/datapackage.csv
curl -qfsL $SOURCE_URL/specification/main/specification/datapackage-dataset.csv > specification/datapackage-dataset.csv


echo Building data package
digital-land organisation-create \
    --cache-dir var/cache/organisation-collection/dataset/ \
    --download-url 'https://files.planning.data.gov.uk/organisation-collection/dataset' \
    --output-path $DATASET_DIR/organisation.csv

echo Checking data package
mkdir -p $CACHE_DIR
curl -qfs https://files.planning.data.gov.uk/dataset/local-planning-authority.csv > $CACHE_DIR/local-planning-authority.csv
digital-land organisation-check --output-path $DATASET_DIR/organisation-check.csv

if [ -n "$DATA_PACKAGE_BUCKET_NAME" ]; then
    echo Pushing package to S3
    aws s3 sync $DATASET_DIR s3://$DATA_PACKAGE_BUCKET_NAME/$DATA_PACKAGE_NAME/$DATASET_DIR --no-progress
else
    echo Not pusing to S3 as DATA_PACKAGE_BUCKET_NAME is not set
fi

ls -l dataset || true

echo Done
