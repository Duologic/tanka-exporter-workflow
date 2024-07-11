local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

ga.workflow.withOn('push')
+ ga.workflow.withJobs({
  show:
    ga.job.withRunsOn('ubuntu-latest')
    + ga.job.withSteps([
      ga.job.step.withName('checkout')
      + ga.job.step.withUses('actions/checkout@v4'),

      ga.job.step.withName('install tanka')
      + ga.job.step.withUses('./.github/actions/install-tanka'),

      ga.job.step.withRun('tk export -r ../_out .')
      + ga.job.step.withWorkingDirectory('jsonnet'),

      ga.job.step.withRun('ls _out'),
    ]),
})
