#!/usr/bin/env bash
set -euo pipefail
# set -x

# This script is used to run backend tests.
# It must be run in a proper 'CI workspace' to find everything it expects (cf setup_workspace.sh script).

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "$THIS_FILE")
ROOT_DIR=$(dirname "$THIS_DIR")
WORKSPACE_DIR="$(dirname "$ROOT_DIR")"

. "$THIS_DIR/kash/kash.sh"

## Parse options
##

NODE_VER=20
MONGO_VER=7
CI_STEP_NAME="Run tests"
CODE_COVERAGE=false
while getopts "m:n:cr:" option; do
    case $option in
        m) # defines mongo version
            MONGO_VER=$OPTARG
            ;;
        n) # defines node version
            NODE_VER=$OPTARG
             ;;
        c) # publish code coverage
            CODE_COVERAGE=true
            ;;
        r) # report outcome to slack
            CI_STEP_NAME=$OPTARG
            load_env_files "$WORKSPACE_DIR/development/common/SLACK_WEBHOOK_APPS.enc.env"
            trap 'slack_ci_report "$ROOT_DIR" "$CI_STEP_NAME" "$?" "$SLACK_WEBHOOK_APPS"' EXIT
            ;;
        *)
            ;;
    esac
done

## Init workspace
##

# TODO: you'll need to adjust the path to the script in the 'development' repository
# responsible for defining required environment variables for the backend tests.
# The script argument is also to update.
. "$WORKSPACE_DIR/development/workspaces/apps/apps.sh" skeleton

## Run tests
##

# TODO: you'll need to adjust the second parameter to match with your $KLI_BASE
run_app_tests "$ROOT_DIR" "workspaces/apps" "$CODE_COVERAGE" "$NODE_VER" "$MONGO_VER"
