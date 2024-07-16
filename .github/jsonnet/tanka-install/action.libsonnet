local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';
local step = ga.action.runs.composite.step;

local common = import 'common/main.libsonnet';

local path = '${{ github.workspace }}/bin';
local key = 'tk-linux-amd64-${{ inputs.version }}';

ga.action.withName('Install Tanka')
+ ga.action.withDescription('Install Tanka from the GitHub releases')
+ ga.action.withInputs({
  version: {
    description: 'Version of Tanka to install.',
    default: '0.27.1',
  },
})
+ ga.action.runs.composite.withUsing()
+ ga.action.runs.composite.withSteps([
  common.cache.restoreStep(path, key),

  step.withIf("steps.restore.outputs.cache-hit != 'true'")
  + common.fetchGitHubReleaseAsset(
    'grafana/tanka',
    'tags/v${{ inputs.version }}',
    'tk-linux-amd64',
    path + '/tk',
  ),

  step.withName('Make tk executable')
  + step.withIf("steps.fetch_asset.outcome == 'success'")
  + step.withShell('sh')
  + step.withRun('chmod +x %s/tk' % path),

  step.withName('Add binary to path')
  + step.withShell('sh')
  + step.withRun('echo "${{ github.workspace }}/bin" >> $GITHUB_PATH'),

  common.cache.saveStep(path, key),
])
