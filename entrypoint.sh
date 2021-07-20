#!/bin/sh -eux

# TODO: check if the revision is in the branch
is_upstream() {
  ## $1 - the upstream
  upstream=$1

  ## $2 - the downstream
  downstream=$2
  
  return 1
}

is_on_branch() {
  ## $1 - the revision
  revision=$1

  ## $2 - the name of the branch
  branch=$1
  return 1
}

# Set default variables that we will define
REVISION=${INPUT_REVISION:=`git rev-parse HEAD~1`}
BRANCH=${INPUT_BRANCH:=main}

cd "${GITHUB_WORKSPACE}"
echo "git branch ${BRANCH}"
echo 'git config --global user.name "github-actions[bot]"'
echo 'git config --global user.email "github-actions[bot]@users.noreply.github.com"'

echo "Checking to see if revision ${REVISION} is on branch \"${BRANCH}\"..."
is_on_branch ${REVISION} ${BRANCH}; if [ $? -eq 0 ]
then
  >&2 echo "Revision ${REVISION} is not on branch ${BRANCH}"
  exit 1
fi

CURRENT_REVISION=$(git rev-parse HEAD)
echo "Checking to see if revision ${REVISION} is an ancestor of the current revision (${CURRENT_REVISION})..."
is_upstream ${REVISION} $(git rev-parse HEAD); if [ $? -eq 0 ]
then
  >&2 echo "Revision ${REVISION} is not an ancestor of the current revision (${CURRENT_REVISION})"
  exit 1
fi

echo "Reverting to revision ${REVISION} on branch \"${BRANCH}\"..."
echo "git reset --hard ${REVISION}"
echo "git push --force"
