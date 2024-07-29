local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local warn = '# Generated, please do not edit.\n';
{
  'actions/jrsonnet-install/action.yaml': warn + ga.util.manifestAction(import './jrsonnet-install/action.libsonnet'),
  'actions/tanka-install/action.yaml': warn + ga.util.manifestAction(import './tanka-install/action.libsonnet'),
  'actions/tanka-exporter/action.yaml': warn + ga.util.manifestAction(import './tanka-exporter/action.libsonnet'),
  'workflows/tanka-exporter.yaml': warn + ga.util.manifestWorkflow(import './tanka-exporter/workflow.libsonnet'),
}
