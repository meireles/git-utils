#!/bin/bash

## https://stackoverflow.com/questions/29229247/how-can-i-allow-git-merge-commits-to-master-but-prevent-non-merge-commits#29230164

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "${BRANCH}" == "master" -a "${GIT_COMMIT_TO_MASTER}" != "true" ]
then
  if [ -e "${GIT_DIR}/MERGE_MODE" ]
  then
    echo "Merge to master is allowed."
    exit 0
  else
    echo "Commit directly to master is discouraged."
    echo "If you want to do this, please set GIT_COMMIT_TO_MASTER=true and then commit."
    exit 1
  fi
fi