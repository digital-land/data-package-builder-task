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