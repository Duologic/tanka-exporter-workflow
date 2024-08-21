local ga = import 'ga.libsonnet';
local gac = ga.action.composite;
local step = gac.runs.step;

local actions = import './actions.libsonnet';

{
  local root = self,

  cache: {
    plainCacheStep(path, key, idSuffix=''):
      step.withName('Setup Cache for ' + key)
      + step.withId('cache' + idSuffix)
      + step.withUses(actions.cache.asUses())
      + step.withWith({
        path: path,
        key: key,
      }),

    restoreStep(path, key, idSuffix=''):
      step.withName('Restore cache ' + key)
      + step.withId('restore' + idSuffix)
      + step.withUses(actions.cacheRestore.asUses())
      + step.withWith({
        path: path,
        key: key,
      }),

    saveStep(path, key, idSuffix=''):
      step.withName('Save to cache ' + key)
      + step.withId('save' + idSuffix)
      + step.withUses(actions.cacheSave.asUses())
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
      + step.withUses(actions.checkout.asUses())
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
      + step.withUses(actions.fetchGhReleaseAsset.asUses())
      + step.withWith({
        repo: repo,
        version: version,
        file: file,
        target: target,
      }),

    generateAction(
      slug,
      repo,
      defaultVersion,
      file,
      target,
    ):
      gac.new(
        slug,
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
        step.withUses(actions.fetch.asUses('_wf'))
        + step.withWith({
          repo: repo,
          version: '${{ inputs.version }}',
          file: file,
          'target-file': target,
        }),
      ]),

    generateRawAction(
      slug,
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

        gac.withSlug(slug)
        + gac.withName('Install %s' % target)
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
