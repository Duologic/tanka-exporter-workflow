local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';


local exportFormat = std.strReplace(|||
  {{ if env.metadata.labels.cluster_name }}{{ env.metadata.labels.cluster_name }}/{{ end }}
  {{ if .metadata.namespace }}{{.metadata.namespace}}
  {{ else }}_cluster
  {{ end }}/
  {{.kind}}-{{.metadata.name}}
|||, '\n', '');

local paths = [
  'jsonnet/**',
  '.github/**',
];

ga.workflow.on.push.withPaths(paths)
+ ga.workflow.on.pull_request.withPaths(paths)
+ ga.workflow.permissions.withContents('write')  // allow git push
+ ga.workflow.withJobs({
  show:
    ga.job.withRunsOn('ubuntu-latest')
    + ga.job.withSteps([
      ga.job.step.withUses('actions/checkout@v4'),

      ga.job.step.withUses('./.github/actions/install-tanka'),

      ga.job.step.withRun('rm -rf manifests/*'),

      ga.job.step.withId('export')
      + ga.job.step.withRun(|||
        tk export \
        --recursive \
        --format '%s' \
        --merge-strategy=fail-on-conflicts \
        ../manifests/ \
        environments/
        if [[ -n $(git status --porcelain ../manifests/) ]]; then
            echo "changes=true" >> $GITHUB_OUTPUT
        fi
      ||| % exportFormat,)
      + ga.job.step.withWorkingDirectory('jsonnet'),

      ga.job.withIf("${{ github.event_name == 'pull_request' }}")
      + ga.job.step.withRun('git checkout -b pr-$PR')
      + ga.job.step.withEnv({ PR: '${{ github.event.number }}' }),

      ga.job.step.withIf("${{ steps.export.outputs.changes == 'true' }}")
      + ga.job.step.withRun(|||
        git add manifests/
        git commit -m "generated"
        git log -1 --format=fuller
        git show HEAD
      |||)
      + ga.job.step.withEnv({
        GIT_AUTHOR_NAME: '${{ github.event.pusher.name }}',
        GIT_AUTHOR_EMAIL: '${{ github.event.pusher.email }}',
        GIT_COMMITTER_NAME: 'github-actions[bot]',
        GIT_COMMITTER_EMAIL: '41898282+github-actions[bot]@users.noreply.github.com',
      }),

      ga.job.withIf("${{ steps.export.outputs.changes == 'true' && github.event_name == 'push' && github.ref == 'refs/head/master' }}")
      + ga.job.step.withRun('git push'),
    ]),
})
