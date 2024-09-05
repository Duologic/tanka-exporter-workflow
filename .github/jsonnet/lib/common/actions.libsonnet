local pinAction = import 'pin-github-actions/main.libsonnet';

local latestVersions = import './latest_actions_from_actions.json';

local pinLatestAction = pinAction.latest(latestVersions);

{
  checkout:
    pinLatestAction.new('actions/checkout'),

  cache:
    pinLatestAction.new('actions/cache'),

  cacheRestore:
    pinLatestAction.new('actions/cache/restore', 'actions/cache'),

  cacheSave:
    pinLatestAction.new('actions/cache/save', 'actions/cache'),

  createGithubAppToken:
    pinLatestAction.new('actions/create-github-app-token'),

  artifactDownload:
    pinLatestAction.new('actions/download-artifact'),

  artifactUpload:
    pinLatestAction.new('actions/upload-artifact'),

  setupGo:
    pinLatestAction.new('actions/setup-go'),

  golangciLint:
    pinLatestAction.new('golangci/golangci-lint-action'),

  dockerLogin:
    pinLatestAction.new('docker/login-action'),

  turnstyle:
    pinLatestAction.new('softprops/turnstyle'),


  kubeconform:
    pinLatestAction.new('hermanbanken/kubeconform-action'),

  verifyChangedFiles:
    pinLatestAction.new('tj-actions/verify-changed-files'),

  setupJsonnet:
    pinLatestAction.new('kobtea/setup-jsonnet-action'),

  pathsFilter:
    pinLatestAction.new('dorny/paths-filter'),

  commentPullRequest:
    pinLatestAction.new('thollander/actions-comment-pull-request'),

  fetchGhReleaseAsset:
    pinLatestAction.new('dsaltares/fetch-gh-release-asset'),


  tankaExporter:
    pinAction.relative.new('./.github/actions/tanka-exporter'),

  fetch:
    pinAction.relative.new('./.github/actions/fetch'),

  tankaInstall:
    pinAction.relative.new('./.github/actions/tanka-install'),

  jrsonnetInstall:
    pinAction.relative.new('./.github/actions/jrsonnet-install'),
}
