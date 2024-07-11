local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';


local exportFormat = std.strReplace(|||
  {{ if env.metadata.labels.cluster_name }}{{ env.metadata.labels.cluster_name }}/{{ end }}
  {{ if .metadata.namespace }}{{.metadata.namespace}}
  {{ else }}_cluster
  {{ end }}/
  {{.kind}}-{{.metadata.name}}
|||, '\n', '');

ga.workflow.withOn('push')
+ ga.workflow.withJobs({
  show:
    ga.job.withRunsOn('ubuntu-latest')
    + ga.job.withSteps([
      ga.job.step.withName('checkout')
      + ga.job.step.withUses('actions/checkout@v4'),

      ga.job.step.withName('install tanka')
      + ga.job.step.withUses('./.github/actions/install-tanka'),

      ga.job.step.withRun(|||
        tk export \
        --recursive \
        --format '%s' \
        --merge-strategy=fail-on-conflicts \
        ../manifests/ \
        environments/
      ||| % exportFormat,)
      + ga.job.step.withWorkingDirectory('jsonnet'),

      ga.job.step.withRun(|||
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
    ]),
})
