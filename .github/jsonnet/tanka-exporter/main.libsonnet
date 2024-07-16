local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

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

ga.workflow.on.push.withPaths(paths)
+ ga.workflow.on.push.withBranches(['main'])
+ ga.workflow.on.pull_request.withPaths(paths)
+ ga.workflow.on.withWorkflowDispatch({})
+ ga.workflow.permissions.withPullRequests('write')  // allow pr comments
+ ga.workflow.permissions.withContents('write')  // allow git push
+ ga.workflow.concurrency.withGroup('${{ github.workflow }}-${{ github.ref }}')  // only run this workflow once per ref
+ ga.workflow.concurrency.withCancelInProgress("${{ github.ref != 'master' }}")  // replace concurrent runs in PRs
+ ga.workflow.withJobs({
  export:
    ga.job.withRunsOn('ubuntu-latest')
    + ga.job.withSteps([
      ga.job.step.withName('Checkout source repository')
      + ga.job.step.withUses('actions/checkout@v4')
      + ga.job.step.withWith({
        ref: '${{ github.event.pull_request.head.sha }}',  // need to read the right commit message
        path: sourceRepo,
      }),

      ga.job.step.withName('Checkout manifest repository')
      + ga.job.step.withUses('actions/checkout@v4')
      + ga.job.step.withWith({
        ref: 'main',
        path: manifestsRepo,
      }),

      ga.job.step.withName('Export Tanka manifests')
      + ga.job.step.withUses('./' + sourceRepo + '/.github/actions/tanka-exporter')
      + ga.job.step.withWith({
        'source-repository': sourceRepo,
        'tanka-root': jsonnetDir,
        'target-repository': manifestsRepo,
        'target-directory': manifestsDir,
      }),
    ]),
})
