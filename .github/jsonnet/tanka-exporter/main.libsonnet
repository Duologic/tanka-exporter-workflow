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

      ga.job.step.withRun(
        std.strReplace(
          |||
            tk export
            --recursive
            --format '%s'
            ../_out
            environments/
          ||| % exportFormat,
          '\n',
          ' '
        )
      )
      + ga.job.step.withWorkingDirectory('jsonnet'),

      ga.job.step.withRun('find _out'),
    ]),
})
