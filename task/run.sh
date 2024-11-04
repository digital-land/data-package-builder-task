set -e

export SOURCE_URL='https://raw.githubusercontent.com/digital-land/'
export DATASET_DIR=dataset
export CACHE_DIR=var/cache

if [ -z "$DATA_PACKAGE_NAME" ]; then
    echo DATA_PACKAGE_NAME not set
    exit 1
fi

if [ -z "$READ_S3_BUCKET" ]; then
    echo READ_S3_BUCKET not set so files will be downloaded from the production files cdn
fi

if [ -z "$WRITE_S3_BUCKET" ]; then
    echo WRITE_S3_BUCKET not set so files will not be uploaded to an S3 Bucket
fi

# TODO should be embedded into package creation code
if [ "$DATA_PACKAGE_NAME" != 'organisation' ]; then
    echo Unspoorted package.
    exit 1
fi

# update digital-land-python
pip install -r ./requirements.txt

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
mkdir -p $CACHE_DIR

if [ -n "$READ_S3_BUCKET" ]; then
    echo Building organisation data package - using collection files from S3 bucket $READ_S3_BUCKET
    aws s3 sync s3://$READ_S3_BUCKET/$DATA_PACKAGE_NAME/$DATASET_DIR $DATASET_DIR --no-progress
    digital-land organisation-create \
        --dataset-dir $DATASET_DIR \
        --output-path $DATASET_DIR/organisation.csv
else
    echo Building organisation data package - using collection files from CDN
    digital-land organisation-create \
        --cache-dir $CACHE_DIR/organisation-collection/dataset/ \
        --download-url 'https://files.planning.data.gov.uk/organisation-collection/dataset' \
        --output-path $DATASET_DIR/organisation.csv
fi

echo Checking data package
curl -qfs https://files.planning.data.gov.uk/dataset/local-planning-authority.csv > $CACHE_DIR/local-planning-authority.csv
digital-land organisation-check --output-path $DATASET_DIR/organisation-check.csv

ls -l $DATASET_DIR || true

# TODO where to permenantly store data packages, also this uploads all the filels in datasets 
if [ -n "$WRITE_S3_BUCKET" ]; then
    echo Pushing package to S3 bucket $WRITE_S3_BUCKET
    aws s3 sync $DATASET_DIR s3://$WRITE_S3_BUCKET/$DATA_PACKAGE_NAME/$DATASET_DIR --no-progress
fi
