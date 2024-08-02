local common = import 'common/main.libsonnet';

local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';
local step = ga.action.runs.composite.step;

local repo = '${{ inputs.repo }}';
local version = '${{ inputs.defaultVersion }}';
local file = '${{ inputs.file }}';
local target = '${{ inputs.target-file }}';
local path = '${{ inputs.target-path }}';
local full_path = path + '/' + target;
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
  common.cache.restoreStep(full_path, cacheKey),

  step.withIf("steps.restore.outputs.cache-hit != 'true'")
  + step.withName('Fetch Github Release Asset')
  + step.withId('fetch_asset')
  + step.withUses('dsaltares/fetch-gh-release-asset@v1')
  + step.withWith({
    repo: repo,
    version: 'tags/v${{ inputs.version }}',
    file: file,
    target: full_path,
  }),

  step.withName('Make %s executable' % target)
  + step.withIf("steps.fetch_asset.outcome == 'success'")
  + step.withShell('sh')
  + step.withRun('chmod +x %s/%s' % [path, target]),

  step.withName('Add binary to path')
  + step.withShell('sh')
  + step.withRun('echo "$TARGET_PATH" >> $GITHUB_PATH')
  + step.withEnv({
    TARGET_PATH: path,
  }),

  common.cache.saveStep(full_path, cacheKey)
  + step.withIf("steps.fetch_asset.outcome == 'success'"),
])
