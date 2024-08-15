export SOURCE_URL='https://raw.githubusercontent.com/digital-land/'

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

echo Downloading datasets
./download-organisation-datasets.py

echo Building data package
digital-land organisation-create --dataset-dir var/cache/organisation-collection/dataset/ --output-path dataset/organisation.csv

echo Checking data package
export CACHE_DIR=var/cache
mkdir -p $CACHE_DIR
curl -qfs https://files.planning.data.gov.uk/dataset/local-planning-authority.csv > $CACHE_DIR/local-planning-authority.csv
digital-land organisation-check --output-path dataset/organisation-check.csv

echo Done
ls -l dataset/