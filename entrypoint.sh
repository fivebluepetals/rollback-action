#!/bin/sh -eux

# TODO: check if the revision is in the branch
is_upstream() {
  ## $1 - the upstream
  upstream=$1

  ## $2 - the downstream
  downstream=$2

  # git merge-base --is-ancestor naturally determines
  # ancestry
  git merge-base --is-ancestor ${upstream} ${downstream}; is_ancestor=$?
  echo ${is_ancestor}
}

is_on_branch() {
  ## $1 - the revision
  revision=$1

  ## $2 - the name of the branch
  branch=$2

  # git branch $2 
  echo $(git branch ${branch} --contains ${revision} | wc -l)
}

# Set default variables that we will define
REVISION=${1:-`git rev-parse HEAD~1`}
BRANCH=${2:-main}

cd "${GITHUB_WORKSPACE}"
git checkout ${BRANCH}
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

echo "Checking to see if revision ${REVISION} is on branch \"${BRANCH}\"..."
if [ ! $(is_on_branch ${REVISION} ${BRANCH}) -eq 1 ]
then
  >&2 echo "Revision ${REVISION} is not on branch ${BRANCH}"
  exit 1
fi

CURRENT_REVISION=$(git rev-parse HEAD)
echo "Checking to see if revision ${REVISION} is an ancestor of the current revision (${CURRENT_REVISION})..."
if [ ! $(is_upstream ${REVISION} ${CURRENT_REVISION}) -eq 0 ]
then
  >&2 echo "Revision ${REVISION} is not an ancestor of the current revision (${CURRENT_REVISION})"
  exit 1
fi

echo "Reverting to revision ${REVISION} on branch \"${BRANCH}\"..."
git reset --hard ${REVISION}
git push --force

time=$(date)
echo "::set-output name=time::$time"
