#!/bin/bash

tmpdir="$(mktemp -d)"

trap 'rm -rf "${tmpdir}"' EXIT

auth_url="${GPG_REPO_URL/https:\/\//https:\/\/${GPG_TOKEN}@}"
repo_dir="${tmpdir}/gpg"

git clone --depth=1 --branch "${GPG_REPO_BRANCH}" "${auth_url}" "${repo_dir}"

mapfile -t asc_files < <(compgen -G "${repo_dir}/${GPG_REPO_ASC_PATH}"/*.asc 2>/dev/null || true)
mapfile -t gpg_files < <(compgen -G "${repo_dir}/${GPG_REPO_GPG_PATH}"/*.gpg 2>/dev/null || true)

files=( "${asc_files[@]}" "${gpg_files[@]}" )

if(( ${#files[@]} == 0 )); then return 52; fi

gpg --batch --import "${files[@]}"