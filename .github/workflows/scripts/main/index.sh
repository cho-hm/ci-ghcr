#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Cho-Hyunmin

set -euo pipefail
tmp="$GITHUB_WORKSPACE/.github/workflows/scripts/env"
. "${tmp}/literal.sh"
. "${tmp}/combine.sh"


trigger_type="${TRIGGER_TYPE}"
branch_list="${BRANCH_LIST}"

if [[ "${trigger_type}" == "signed-tag" ]] || [[ "${trigger_type}" == "tag" ]]; then
  if [[ "${GITHUB_REF_TYPE:-}" != "tag" ]] && [[ "${GITHUB_REF:-}" != refs/tags/* ]]; then
    echo "Expected ``trigger.type``=${trigger_type}, but actual: ${GITHUB_REF_TYPE}"
    echo "Invalid trigger type, reject ci silently..."
    exit 0
  fi
else
  if [[ "${GITHUB_REF_TYPE:-}" == "tag" ]] || [[ "${GITHUB_REF:-}" == refs/tags/* ]]; then
    echo "Expected ``trigger.type``=${trigger_type}, but actual: ${GITHUB_REF_TYPE}"
    echo "Invalid trigger type, reject ci silently..."
    exit 0
  fi
fi


. "${valid_path}/${fnVALIDATE}" || {
  if(("$?" == 47 )); then
      echo "First commit, silently close..."
  fi
  exit 0
}

declare -A MAP_FILE_TRIGGER_TYPE=(
  [tag]="${TAG}"
  [branch]="${BRANCH}"
  ["signed-tag"]="${SIGNED_TAG}"
)

CI_TYPE="commit"
echo "=== trigger type: ${trigger_type}"

TRIGGER_TYPE_FILE="${MAP_FILE_TRIGGER_TYPE["${trigger_type}"]}"
. "${TRIGGER_TYPE_FILE}" || {
  code=$?
  echo "=== $code"

  if(( "${code}" == 52 )); then echo "GPG_KEY REPO is EMPTY...";
  elif(( "${code}" == 54 )); then echo "No matched branch";
  elif(( "${code}" == 53 )); then echo "No Signed Tag commit...";
  elif(( "${code}" == 57 )); then echo "Nothing valid GPG KEY in gpg repo...";
  elif(( "${code}" == 51 )); then echo "Can not connect to GPG REPO... Check GPG key... or else...";
  else
    echo "Invalid ci-property options.. check the property file.."
    echo "exit with code ${code}"
    exit "${code}"
  fi
  exit "${code}"
}
CI_TYPE=trigger_type

echo "=== Okay, you can continue next stage! ==="
echo "continue=true" >> "$GITHUB_OUTPUT"
