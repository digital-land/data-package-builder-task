#! /bin/bash

set -e

exit 1

TODAY=$(date +%Y-%m-%d)
echo "Running package builder for $DATA_PACKAGE_NAME on $TODAY"

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

# Setup
pyproj sync --file uk_os_OSTN15_NTv2_OSGBtoETRS.tif -v
dpkg-query -W libsqlite3-mod-spatialite >/dev/null 2>&1 || sudo apt-get install libsqlite3-mod-spatialite -y
dpkg-query -W -f="\${Package} - \${Version}\n" libsqlite3-mod-spatialite

# update digital-land-python
pip install -r ./requirements.txt

# We should be importing the makerules repo and using that to download specification
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
curl -qfsL $SOURCE_URL/specification/main/specification/provision-rule.csv > specification/provision-rule.csv
curl -qfsL $SOURCE_URL/specification/main/specification/pipeline.csv > specification/pipeline.csv
curl -qfsL $SOURCE_URL/specification/main/specification/dataset-schema.csv > specification/dataset-schema.csv
curl -qfsL $SOURCE_URL/specification/main/specification/schema.csv > specification/schema.csv
curl -qfsL $SOURCE_URL/specification/main/specification/schema-field.csv > specification/schema-field.csv
curl -qfsL $SOURCE_URL/specification/main/specification/datapackage.csv > specification/datapackage.csv
curl -qfsL $SOURCE_URL/specification/main/specification/datapackage-dataset.csv > specification/datapackage-dataset.csv

echo Building data package
mkdir -p $CACHE_DIR

export COLLECTION_NAME=$DATA_PACKAGE_NAME-collection
export COLLECTION_DATASET_DIR=$CACHE_DIR/$COLLECTION_NAME/dataset/

if [ -n "$READ_S3_BUCKET" ]; then
    echo Building organisation data package - using collection files from S3 bucket $READ_S3_BUCKET
    mkdir -p $COLLECTION_DATASET_DIR
    aws s3 sync s3://$READ_S3_BUCKET/$COLLECTION_NAME/$DATASET_DIR $COLLECTION_DATASET_DIR --no-progress
    digital-land organisation-create \
        --dataset-dir $COLLECTION_DATASET_DIR \
        --output-path $DATASET_DIR/organisation.csv
else
    echo Building organisation data package - using collection files from CDN
    digital-land organisation-create \
        --cache-dir $COLLECTION_DATASET_DIR \
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
    aws s3 sync $DATASET_DIR s3://$WRITE_S3_BUCKET/$COLLECTION_NAME/$DATASET_DIR --no-progress
fi
