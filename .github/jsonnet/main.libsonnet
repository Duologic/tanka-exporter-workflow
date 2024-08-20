local c = import './lib/comments/main.libsonnet';
local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local warn = '# Generated, please do not edit.\n';
{
  'actions/fetch/action.yaml': warn + (import './fetch/action.libsonnet').manifest(),
  'actions/jrsonnet-install/action.yaml': warn + (import './jrsonnet-install/action.libsonnet').manifest(),
  'actions/tanka-install/action.yaml': warn + (import './tanka-install/action.libsonnet').manifest(),
  'actions/tanka-exporter/action.yaml': warn + (import './tanka-exporter/action.libsonnet').manifest(),
  'workflows/tanka-exporter.yaml':
    local commenter =
      c.new(warn + (import './tanka-exporter/workflow.libsonnet').manifest())
      + c.addComment(
        'contents: write',
        'give push permissions to GITHUB_TOKEN',
      )
      + c.addComment(
        'pull-requests: write',
        'give permission to comment on the pull request',
      )
      + c.addComment(
        'concurrency:',
        |||
          limit concurrency
          but only cancel when in PRs
        |||,
      );

    commenter.apply(),
}
