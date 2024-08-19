local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';
local job = ga.workflow.job;
local step = job.step;

local common = import 'common/main.libsonnet';

/* TODO:
 * - Rebase on last export (needed for high-traffic repositories)
 * - Surface all authors on a PR merge
 * - Handling of multiple commit messages exported (related to rebase)
 * NICE TO HAVE:
 * - Expand change message
 *      - add warnings for destructive actions (namespace/CRD/kustomization deletion)
 *      - list changed enviroments (perhaps with groupings)
 */

local sourceRepo = '_source';
local jsonnetDir = 'jsonnet';
local manifestsRepo = '_manifests';
local manifestsDir = 'manifests';

local paths = [
  jsonnetDir + '/**',
  '.github/**',
];

ga.workflow.new('Export Tanka manifests')
+ ga.workflow.on.push.withPaths(paths)
+ ga.workflow.on.push.withBranches(['main'])
+ ga.workflow.on.pull_request.withPaths(paths)
+ ga.workflow.on.withWorkflowDispatch({})
+ ga.workflow.permissions.withPullRequests('write')  // allow pr comments
+ ga.workflow.permissions.withContents('write')  // allow git push
+ ga.workflow.concurrency.withGroup('${{ github.workflow }}-${{ github.ref }}')  // only run this workflow once per ref
+ ga.workflow.concurrency.withCancelInProgress("${{ github.ref != 'master' }}")  // replace concurrent runs in PRs
+ ga.workflow.withJobs({
  export:
    job.withName('Export Tanka manifests')
    + job.withRunsOn('ubuntu-latest')
    + job.withOutputs({
      files_changed: '${{ steps.export.outputs.files_changed }}',
      changed_files: '${{ steps.export.outputs.changed_files }}',
      commit_sha: '${{ steps.export.outputs.commit_sha }}',
    })
    + job.withSteps([
      step.withName('Checkout source repository')
      + step.withUses('actions/checkout@v4')
      + step.withWith({
        ref: '${{ github.event.pull_request.head.sha }}',  // need to read the right commit message
        path: sourceRepo,
      }),

      step.withName('Checkout manifest repository')
      + step.withUses('actions/checkout@v4')
      + step.withWith({
        ref: 'main',
        path: manifestsRepo,
      }),

      step.withName('Export Tanka manifests')
      + step.withId('export')
      + step.withUses('./' + sourceRepo + '/.github/actions/tanka-exporter')
      + step.withWith({
        'source-repository': sourceRepo,
        'tanka-root': jsonnetDir,
        'target-repository': manifestsRepo,
        'target-directory': manifestsDir,
      }),
    ]),

  local lintJob(name) =
    job.withName('Lint changed files with %s' % name)
    + job.withIf("${{ needs.export.outputs.files_changed == 'true' }}")
    + job.withRunsOn('ubuntu-latest')
    + job.withNeeds('export')
    + job.withSteps([
      step.withName('Checkout source repository')
      + step.withUses('actions/checkout@v4')
      + step.withWith({
        ref: '${{ needs.export.outputs.commit_sha }}',
      }),
    ]),
  kubeconform:
    lintJob('Kubeconform')
    + job.withStepsMixin([
      step.withUses('hermanbanken/kubeconform-action@v1')
      + step.withWith({
        args:
          std.join(' ', [
            '-output',
            'json',
            '${{ needs.export.outputs.changed_files }}',
          ]),
      }),
    ]),

  validate:
    job.withName('Validate lib/meta/raw/environments.json')
    + job.withRunsOn('ubuntu-latest')
    + job.withSteps([
      step.withName('Checkout source repository')
      + step.withUses('actions/checkout@v4'),

      step.withName('Install Tanka')
      + step.withUses('./.github/actions/tanka-install'),

      step.withName('Install jrsonnet')
      + step.withUses('./.github/actions/jrsonnet-install'),

      step.withName('Run make lib/meta/raw/environments.json')
      + step.withRun('make lib/meta/raw/environments.json')
      + step.withWorkingDirectory('jsonnet'),

      step.withName('Check if file changed')
      + step.withId('changed')
      + step.withUses('tj-actions/verify-changed-files@v20')
      + step.withWith({ files: 'jsonnet' }),

      step.withName('No files changed')
      + step.withIf("${{ steps.changed.outputs.files_changed == 'true' }}")
      + step.withEnv({
        CHANGED_FILES: '${{ steps.changed.outputs.changed_files }}',
      })
      + step.withRun("echo 'Please run `make lib/meta/raw/environments.json`' && exit 1"),
    ]),
})
