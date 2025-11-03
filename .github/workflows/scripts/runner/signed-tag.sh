#! /bin/bash

git fetch --force --prune origin "+refs/tags/*:refs/tags/*"

mapfile -t TAGS < <(git tag --points-at "${GITHUB_SHA}")
ann=""
for t in "${TAGS[@]}"; do
  if git rev-parse -q --verify "refs/tags/$t^{tag}" >/dev/null; then
    ann="$t"; break
  fi
done

if [[ -z "$ann" ]]; then
  return 53
fi

. "${util_path}/gpg-key-provider.sh" || { return $?; }

echo "=== target tag is: ${ann}"

git verify-tag -v "refs/tags/$ann" || return 57
