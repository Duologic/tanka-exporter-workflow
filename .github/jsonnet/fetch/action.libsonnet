local common = import 'common/main.libsonnet';

local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

common.fetchGitHubRelease.generateAction(
  repo='${{ inputs.repo }}',
  defaultVersion='${{ inputs.defaultVersion }}',
  file='${{ inputs.file }}',
  target='${{ inputs.target-file }}',
  path='${{ inputs.target-path }}',
  cacheKey='${{ inputs.cache-key }}'
)
+ ga.action.withName('Fetch GitHub Release asset with cache')
+ ga.action.withDescription(|||
  This action fetches a GitHub Release asset and adds it to PATH.
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

  'cache-key':
    ga.action.input.withRequired()
    + ga.action.input.withDescription('Target path for binary.')
    + ga.action.input.withDefault('${{ inputs.file }}-${{ inputs.version }}'),
})

