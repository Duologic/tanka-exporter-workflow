local common = import 'common/main.libsonnet';

common.fetchGitHubRelease.generateAction(
  repo='CertainLach/jrsonnet',
  defaultVersion='0.5.0-pre96-test',
  file='jrsonnet-linux-amd64',
  target='jrsonnet',
)
