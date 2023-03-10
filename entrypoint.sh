#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master"]
then
  echo "Destination head branch cannot be 'main' nor 'master'"
  return -1
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER/
cp -R "$INPUT_SOURCE_FOLDER/." "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"
echo "Files copied to target directory";
cd "$CLONE_DIR"
git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
  echo "Pushing git commit"
  if [ $INPUT_ALLOW_FORCE_PUSH == "false" ]
  then
    git push -u origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH
  else
    echo "Force push enabled"
    git pull --rebase HEAD:$INPUT_DESTINATION_HEAD_BRANCH
    git push -uf origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH
    return 0
  fi
else
  echo "No changes detected"
fi
