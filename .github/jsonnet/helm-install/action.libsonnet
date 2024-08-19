local common = import 'common/main.libsonnet';

common.fetchGitHubRelease.generateAction(
  repo='grafana/tanka',
  defaultVersion='0.27.1',
  file='tk-linux-amd64',
  target='tk',
)