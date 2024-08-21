#!/usr/bin/env bash

function get_latest() {
  REPO=$1
  URL=$(gh api repos/$REPO/releases/latest | jq -r .url)
  TAG_NAME=$(gh api ${URL//https:\/\/api.github.com\///} | jq -r .tag_name)
  COMMIT_SHA=$(gh api repos/$REPO/git/refs/tags/$TAG_NAME | jq -r .object.sha)

  cat <<EOF
{
  repo: "$REPO",
  tag: "$TAG_NAME",
  sha: "$COMMIT_SHA",
},
EOF
}

DIRNAME=$(dirname "$0")

repos=$(jsonnet --tla-code-file "input=$1" -S "$DIRNAME/lookup.jsonnet")

{
  echo [
  for repo in ${repos[@]}; do
    get_latest $repo
  done
  echo ]
} | jsonnet -
