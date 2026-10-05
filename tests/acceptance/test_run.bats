#!/usr/bin/env bats

# test_run_python_script.bats

# Test if the Bash script runs the Python script and doesn't fail
@test "script runs" {
    export DATA_PACKAGE_NAME=organisation

    function curl() {
        echo ""
    }

    function digital-land() {
        echo ""
    }

    export -f curl
    export -f digital-land

    # change to the task directory
    cd task

    # Run the Bash script and capture the output
    run ./run.sh

    # Assert that the exit status is 0 (success)
    [ "$status" -eq 0 ]
}

@test "script passes the environment to organisation-create" {
    export DATA_PACKAGE_NAME=organisation
    export ENVIRONMENT=staging
    export READ_S3_BUCKET=test-bucket
    export DIGITAL_LAND_ARGS="$BATS_TEST_TMPDIR/digital-land-args"

    function curl() {
        echo ""
    }

    function aws() {
        echo ""
    }

    function digital-land() {
        echo "$@" >> "$DIGITAL_LAND_ARGS"
    }

    export -f curl
    export -f aws
    export -f digital-land

    # change to the task directory
    cd task

    # Run the Bash script and capture the output
    run ./run.sh

    # The environment must reach organisation-create, or every environment
    # gets every organisation dataset
    [ "$status" -eq 0 ]
    grep -q -- "organisation-create .*--environment staging" "$DIGITAL_LAND_ARGS"
}

@test "script fails on empty package name" {
    export DATA_PACKAGE_NAME=''

    # change to the task directory
    cd task

    # Run the Bash script and capture the output
    run ./run.sh

    # Assert that the exit status is 0 (success)
    [ "$status" -eq 1 ]
}

@test "script fails on invalid package name" {
    export DATA_PACKAGE_NAME='bananas'

    # change to the task directory
    cd task

    # Run the Bash script and capture the output
    run ./run.sh

    # Assert that the exit status is 0 (success)
    [ "$status" -eq 1 ]
}