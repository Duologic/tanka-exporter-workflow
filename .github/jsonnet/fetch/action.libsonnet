local common = import 'common/main.libsonnet';

local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';
local gac = ga.action.composite;
local step = gac.runs.step;

local targetFile = '${{ inputs.target-file }}';
local targetPath = '${{ inputs.target-path }}';
local fullTargetPath = targetPath + '/' + targetFile;
local cacheKey = '${{ github.workflow }}:${{ inputs.file }}:${{ inputs.version }}';

gac.new(
  'Fetch GitHub Release binary',
  |||
    Generic action fetches a GitHub Release binary and add it to PATH. The binary will be cached to speed up next runs.
  |||
)
+ gac.withInputs({
  repo:
    gac.input.withRequired()
    + gac.input.withDescription('Repository to pull the release from'),

  version:
    gac.input.withRequired()
    + gac.input.withDescription('Version to install.'),

  file:
    gac.input.withRequired()
    + gac.input.withDescription('The name of the file to be downloaded.'),

  'target-file':
    gac.input.withRequired()
    + gac.input.withDescription('Target filename for binary.'),

  'target-path':
    gac.input.withRequired()
    + gac.input.withDescription('Target path for binary.')
    + gac.input.withDefault('${{ github.workspace }}/bin'),
})

+ gac.runs.withSteps([
  common.cache.restoreStep(fullTargetPath, cacheKey),

  step.withName('Fetch Github Release Asset')
  + step.withId('fetch_asset')
  + step.withIf("steps.restore.outputs.cache-hit != 'true'")
  + step.withUses('dsaltares/fetch-gh-release-asset@master')
  + step.withWith({
    repo: '${{ inputs.repo }}',
    version: 'tags/v${{ inputs.version }}',
    file: '${{ inputs.file }}',
    target: fullTargetPath,
  }),

  step.withName('Make %s executable' % targetFile)
  + step.withId('make_executable')
  + step.withIf("steps.fetch_asset.outcome == 'success'")
  + step.withShell('sh')
  + step.withRun('chmod +x $FULL_PATH')
  + step.withEnv({
    FULL_PATH: fullTargetPath,
  }),

  step.withName('Add binary to path')
  + step.withId('add_to_path')
  + step.withShell('sh')
  + step.withRun('echo "$TARGET_PATH" >> $GITHUB_PATH')
  + step.withEnv({
    TARGET_PATH: targetPath,
  }),

  common.cache.saveStep(fullTargetPath, cacheKey)
  + step.withIf("steps.fetch_asset.outcome == 'success'"),
])
