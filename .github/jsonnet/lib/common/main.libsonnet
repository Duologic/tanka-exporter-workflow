local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local gac = ga.action.composite;
local step = gac.runs.step;

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

    generateAction(
      repo,
      defaultVersion,
      file,
      target,
    ):
      gac.new(
        'Install %s' % target,
        'Install %s from the GitHub releases' % target
      )
      + gac.withInputs({
        version: {
          description: 'Version of %s to install.' % target,
          default: defaultVersion,
        },
      })
      + gac.runs.withUsing()
      + gac.runs.withSteps([
        root.actionRepo.checkoutStep('_wf'),
        step.withUses('./_wf/.github/actions/fetch')
        + step.withWith({
          repo: repo,
          version: '${{ inputs.version }}',
          file: file,
          'target-file': target,
        }),
      ]),

    generateRawAction(
      repo,
      defaultVersion,
      file,
      target,
    ):
      (import '../../fetch/action.libsonnet')
      + (
        local targetFile = '${{ inputs.target-file }}';
        local targetPath = '${{ inputs.target-path }}';
        local fullTargetPath = targetPath + '/' + targetFile;
        local cacheKey = '${{ github.workflow }}:${{ inputs.file }}:${{ inputs.version }}';

        gac.withName('Install %s' % target)
        + gac.withDescription('Install %s from the GitHub releases' % target)
        + gac.withInputsMixin({
          repo+: gac.input.withDefault(repo),
          version+: gac.input.withDefault(defaultVersion),
          file+: gac.input.withDefault(file),
          'target-file'+: gac.input.withDefault(target),
        })
      ),
  },
}
