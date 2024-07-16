# Tanka Exporter for GitHub Actions

This repository contains a composite GitHub Action to export Kubernetes manifests to git using [Tanka](tanka.dev).

_Really? Where does this come from?_ This is a reference implementation of the CI/CD workflow used within Grafana Labs.

The internal process is a Go program that does the same thing :tm:, I figured it would be fun to implement this same process as a 'native' composite action.
