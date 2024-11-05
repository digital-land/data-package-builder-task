set -e

if [ -z "$DATA_PACKAGE_NAME" ]; then
    echo DATA_PACKAGE_NAME not set
    exit 1
fi

# Setup
make makerules
make init

# Run
make $DATA_PACKAGE_NAME-package
make save-$DATA_PACKAGE_NAME-package
