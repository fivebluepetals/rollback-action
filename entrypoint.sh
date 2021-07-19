#!/bin/sh -eux
cd "${GITHUB_WORKSPACE}"

# TODO: check if the revision is in the branch
# TODO: set revision to HEAD~1 if it isn't set

echo "git branch ${INPUT_BRANCH}"
# git config --global user.name "github-actions[bot]"
# git config --global user.email "github-actions[bot]@users.noreply.github.com"
echo "git reset --hard ${INPUT_REVISION}"
echo "git push --force"
