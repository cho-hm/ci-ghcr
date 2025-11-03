#! /usr/bin/env bash

readonly PROPERTY_FILE_NAME="ci-${CI_NAME}.properties"
readonly path="$GITHUB_WORKSPACE/.github/workflows"
readonly script_path="${path}/scripts"
readonly runner_path="${script_path}/runner"
readonly valid_path="${script_path}/valid"
readonly env_path="${script_path}/env"
readonly util_path="${script_path}/util"

readonly APP_ROOT="${path%%/.github*}"
readonly BRANCH="${runner_path}/${fnBRANCH}"
readonly SIGNED_TAG="${runner_path}/${fnSIGNED_TAG}"
readonly TAG="${runner_path}/${fnTAG}"

readonly PROP_KEY_TRIGGER_TYPE="${sTRIGGER_TYPE}"
readonly PROP_KEY_TRIGGER_BRANCH="${sTRIGGER_BRANCH}"
