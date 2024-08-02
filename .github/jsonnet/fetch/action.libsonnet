local common = import 'common/main.libsonnet';

local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';
local step = ga.action.runs.composite.step;

local targetFile = '${{ inputs.target-file }}';
local targetPath = '${{ inputs.target-path }}';
local fullTargetPath = targetPath + '/' + targetFile;
local cacheKey = '${{ github.workflow }}:${{ inputs.file }}:${{ inputs.version }}';

ga.action.withName('Fetch GitHub Release binary')
+ ga.action.withDescription(|||
  Generic action fetches a GitHub Release binary and add it to PATH. The binary will be cached to speed up next runs.
|||)
+ ga.action.withInputs({
  repo:
    ga.action.input.withRequired()
    + ga.action.input.withDescription('Repository to pull the release from'),

  version:
    ga.action.input.withRequired()
    + ga.action.input.withDescription('Version to install.'),

  file:
    ga.action.input.withRequired()
    + ga.action.input.withDescription('The name of the file to be downloaded.'),

  'target-file':
    ga.action.input.withRequired()
    + ga.action.input.withDescription('Target filename for binary.'),

  'target-path':
    ga.action.input.withRequired()
    + ga.action.input.withDescription('Target path for binary.')
    + ga.action.input.withDefault('${{ github.workspace }}/bin'),
})

+ ga.action.runs.composite.withUsing()
+ ga.action.runs.composite.withSteps([
  common.cache.restoreStep(fullTargetPath, cacheKey),

  step.withIf("steps.restore.outputs.cache-hit != 'true'")
  + step.withName('Fetch Github Release Asset')
  + step.withId('fetch_asset')
  + step.withUses('dsaltares/fetch-gh-release-asset@master')
  + step.withWith({
    repo: '${{ inputs.repo }}',
    version: 'tags/v${{ inputs.version }}',
    file: '${{ inputs.file }}',
    target: fullTargetPath,
  }),

  step.withName('Make %s executable' % targetFile)
  + step.withIf("steps.fetch_asset.outcome == 'success'")
  + step.withShell('sh')
  + step.withRun('chmod +x $FULL_PATH')
  + step.withEnv({
    FULL_PATH: fullTargetPath,
  }),

  step.withName('Add binary to path')
  + step.withShell('sh')
  + step.withRun('echo "$TARGET_PATH" >> $GITHUB_PATH')
  + step.withEnv({
    TARGET_PATH: targetPath,
  }),

  common.cache.saveStep(fullTargetPath, cacheKey)
  + step.withIf("steps.fetch_asset.outcome == 'success'"),
])
