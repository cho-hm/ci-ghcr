#! /bin/bash

tags="$(git tag --points-at "${GITHUB_SHA}")"
if [[ -z "${tags}" ]]; then
  return 49
fi

cur_tag=$(git describe --exact-match --tags "${GITHUB_SHA}")
if [[ "${cur_tag}" != "${GITHUB_REF_NAME}" ]]; then
  return 59
fi

