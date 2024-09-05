#!/usr/bin/env bash

DIRNAME=$(dirname "$0")
GITHUB_DIR=$(readlink -f ${1:-.github})

yamls=$(find "$GITHUB_DIR/workflows" "$GITHUB_DIR/actions" -name '*.yml' -o -name '*.yaml' -type f)

{
  echo [
  for yaml in ${yamls[@]}; do
    echo "importstr '$yaml',"
  done
  echo ]
} | jsonnet --tla-code-file 'input=/dev/stdin' "$DIRNAME/usedActions.libsonnet"
