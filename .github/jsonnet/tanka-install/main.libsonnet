local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local step = ga.action.runs.composite.step;

// TODO: make reusable steps available through library

local cache = {
  restoreStep(path, key):
    step.withName('Restore cache ' + key)
    + step.withId('restore-' + key)
    + step.withUses('actions/cache/restore@v4')
    + step.withWith({
      path: path,
      key: key,
    }),

  saveStep(path, key):
    step.withName('Save to cache ' + key)
    + step.withId('save-' + key)
    + step.withUses('actions/cache/save@v4')
    + step.withWith({
      path: path,
      key: key,
    }),
};

local fetchGitHubReleaseAsset(repo, version, file, target) =
  step.withName('Fetch Github Release Asset')
  + step.withId('fetch_asset')
  + step.withUses('dsaltares/fetch-gh-release-asset@master')
  + step.withWith({
    repo: repo,
    version: version,
    file: file,
    target: target,
  });

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
  cache.restoreStep(path, key),

  step.withIf("steps.restore-%s.outputs.cache-hit != 'true'" % key)
  + fetchGitHubReleaseAsset(
    'grafana/tanka',
    'tags/v${{ inputs.version }}',
    'tk-linux-amd64',
    path + '/tk',
  ),

  step.withName('Make tk executable')
  + step.withId('chmod')
  + step.withIf("steps.fetch_asset.outcome == 'success'")
  + step.withShell('sh')
  + step.withRun('chmod +x %s/tk' % path),

  cache.saveStep(path, key),
])
