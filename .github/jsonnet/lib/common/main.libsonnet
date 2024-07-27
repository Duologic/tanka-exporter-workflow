local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local step = ga.action.runs.composite.step;

{
  local root = self,

  cache: {
    restoreStep(path, key, idSuffix=''):
      step.withName('Restore cache ' + key)
      + step.withId('restore' + idSuffix)
      + step.withUses('actions/cache/restore@v4')
      + step.withWith({
        path: path,
        key: key,
      }),

    saveStep(path, key, idSuffix=''):
      step.withName('Save to cache ' + key)
      + step.withId('save' + idSuffix)
      + step.withUses('actions/cache/save@v4')
      + step.withWith({
        path: path,
        key: '${{ steps.restore%s.outputs.cache-primary-key }}' % idSuffix,
      }),
  },

  fetchGitHubReleaseAsset(repo, version, file, target):
    step.withName('Fetch Github Release Asset')
    + step.withId('fetch_asset')
    + step.withUses('dsaltares/fetch-gh-release-asset@master')
    + step.withWith({
      repo: repo,
      version: version,
      file: file,
      target: target,
    }),

  actionRepo: {
    // When a Composite action uses an action relative in the same repository, it'll need to do a checkout of that repository so that downstream usage can access it.
    checkoutStep(path):
      step.withName('Checkout')
      + step.withEnv({
        action_repo: '${{ github.action_repository }}',
        action_ref: '${{ github.action_ref }}',
      })
      + step.withUses('actions/checkout@v4')
      + step.withWith({
        repository: '${{ env.action_repo }}',
        ref: '${{ env.action_ref }}',
        path: path,
      }),
  },

  fetchGitHubRelease: {

    step(repo, version, file, target):
      step.withName('Fetch Github Release Asset')
      + step.withId('fetch_asset')
      + step.withUses('dsaltares/fetch-gh-release-asset@master')
      + step.withWith({
        repo: repo,
        version: version,
        file: file,
        target: target,
      }),

    generateAction(repo, defaultVersion, file, target):
      local path = '${{ github.workspace }}/bin';
      local key = '%s-${{ inputs.version }}' % file;

      ga.action.withName('Install %s' % target)
      + ga.action.withDescription('Install %s from the GitHub releases' % target)
      + ga.action.withInputs({
        version: {
          description: 'Version of %s to install.' % target,
          default: defaultVersion,
        },
      })
      + ga.action.runs.composite.withUsing()
      + ga.action.runs.composite.withSteps([
        root.cache.restoreStep(path, key),

        step.withIf("steps.restore.outputs.cache-hit != 'true'")
        + self.step(
          repo,
          'tags/v${{ inputs.version }}',
          file,
          path + '/' + target,
        ),

        step.withName('Make %s executable' % target)
        + step.withIf("steps.fetch_asset.outcome == 'success'")
        + step.withShell('sh')
        + step.withRun('chmod +x %s/%s' % [path, target]),

        step.withName('Add binary to path')
        + step.withShell('sh')
        + step.withRun('echo "${{ github.workspace }}/bin" >> $GITHUB_PATH'),

        root.cache.saveStep(path, key)
        + step.withIf("steps.fetch_asset.outcome == 'success'"),
      ]),
  },
}
