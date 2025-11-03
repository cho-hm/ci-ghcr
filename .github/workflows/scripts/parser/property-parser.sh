#! /usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Cho-Hyunmin

set -euo pipefail
shopt -s extglob

. "${GITHUB_WORKSPACE}/.github/workflows/scripts/parser/set-default.sh"
FILE_PATH="${GITHUB_WORKSPACE}/ci-ghcr.properties"

if [ -r "${FILE_PATH}" ]; then
  while IFS= read -r line || [[ -n $line ]]; do
    [[ $line =~ ^[[:space:]]*$ ]] && continue
    [[ $line =~ ^[[:space:]]*# ]] && continue

    line=${line%$'\r'}

    key=${line%%=*}
    value=${line#*=}
    key=${key##+([[:space:]])}
    key=${key%%+([[:space:]])}
    value=${value##+([[:space:]])}
    value=${value%%+([[:space:]])}

    [[ -z $key ]] && continue



    if [[ "$value" == \"*\" && "$value" == *\" ]] || [[ "$value" == \'*\' && $value == *\' ]]; then
      value="${value:1:-1}"
    else
      value="${value%%#*}"
      value="${value%%+([[:space:]])}"
    fi

    out_key="$key"
    out_key="${out_key^^}"
    out_key="${out_key//./_}"
    echo "${out_key}=${value}" >> "${GITHUB_OUTPUT}"

  done < "${FILE_PATH}"
fi


img_suffix="$(tac "${GITHUB_OUTPUT}" | grep -m1 '^IMAGE_NAME_SUFFIX=' | cut -d= -f2-)"
IFS=":" read -r -a each <<< "${img_suffix}"
for v in "${each[@]}"; do
  tv="IMAGE_NAME_SUFFIX_${v^^}"
  tv="${tv//-/_}"
  echo "${tv}=true" >> "${GITHUB_OUTPUT}"
done