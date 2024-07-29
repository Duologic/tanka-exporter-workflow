local common = import 'common/main.libsonnet';
{
  'actions/jrsonnet-install/action.yaml': common.manifestAction(import './jrsonnet-install/action.libsonnet'),
  'actions/tanka-install/action.yaml': common.manifestAction(import './tanka-install/action.libsonnet'),
  'actions/tanka-exporter/action.yaml': common.manifestAction(import './tanka-exporter/action.libsonnet'),
  'workflows/tanka-exporter.yaml': common.manifestWorkflow(import './tanka-exporter/workflow.libsonnet'),
}
