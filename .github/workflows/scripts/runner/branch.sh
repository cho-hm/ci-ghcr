#! /bin/bash

if [[ "${GITHUB_REF_TYPE}" != "branch" ]]; then
  return 87
fi

if [[ -z "${BRANCH_LIST}" ]]; then
  return 20;
fi

IFS=":" read -r -a LIST <<< "${BRANCH_LIST}"

not_in=true
for x in "${LIST[@]}"; do
  if [[ "$x" == "${GITHUB_REF_NAME}" ]]; then
    echo "=== matched branch: $x"
    not_in=false;
    break;
  fi
done

if "${not_in}"; then
  return 52
fi
