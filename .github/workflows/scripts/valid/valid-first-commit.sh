#!/bin/bash

if [[ -n "$(git diff --diff-filter=A --name-only HEAD^..HEAD | grep "${CI_FULL_NAME}")" ]]; then
  return 47
fi