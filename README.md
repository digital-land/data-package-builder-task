# data-package-builder-task
An ECS task to build a data package. Currently the only package build is the organisaion package (organisation.csv).

## How To Use This Template

Files/Folders:

```
requirements - Folder to contain python requirements, these will be added to the image
    requirements.in - file which piptools can use to generate requirements file
    requirements.txt - generated  using piptools, acts as a lockfile for the python dependencies
task - Folder containing the source code for the task. This folder is copied into the docker container and is the working directory
    run.sh - the shell script that is ran when the container is started
    .... - other files needed to support run.sh
tests - Foder containing the tests for the task these will depend ont he task itself but should follow testing guidance.
Dockerfile - file that is used to
Makefile - use file containing make targets for running the task locally
README.md - contains detaills on the ecs task, including information on dependencies and how to run locally
```

1. Create a repo from the template
2. Alter code, add tests update README (Remove this section and update the others)
3. reach out to infrastructure to register task and create definition
4. deploy into development to check it works
5. deploy to staging and production

## Dependencies


## how to run locally

this task can be ran either with or without docker the instructions for either are below

### Without Docker

set up dependencies:

* create a virtual environment for python and activate it
* run make init to install local
* run make run-task

then because the task needs to be ran from the task directory you need to change into the task directorry

`cd task`

then the task can be ran using the entrypoint scrript

`./run.sh`

it can also be ran without changing directory by using the make commands

`make run-task`

### With Docker

With docker we have created a docker compose file which allows you to run it locally . First install the depencies:

* Install docker.

now run the docker compose code using

```
docker compose up
```

this will start the container and print the logs into the terminal.


## How to run tests

Tests run locally, there are a few depencies to have innstalled to use them:

* create a virtual environment
* run make init to install the test dependencies
* install BATS to test the bash scripts used to trigger/orchestrate cde  within the container

tests can then be ran using

`make test`

there  are individual make targets for unit  and  acceptance tests

`makw unit`
`make acceptance`
