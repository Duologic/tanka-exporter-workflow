local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local warn = '# Generated, please do not edit.\n';
{
  'actions/fetch/action.yaml': warn + (import './fetch/action.libsonnet').manifest(),
  'actions/jrsonnet-install/action.yaml': warn + (import './jrsonnet-install/action.libsonnet').manifest(),
  'actions/tanka-install/action.yaml': warn + (import './tanka-install/action.libsonnet').manifest(),
  'actions/tanka-exporter/action.yaml': warn + (import './tanka-exporter/action.libsonnet').manifest(),
  'workflows/tanka-exporter.yaml': warn + (import './tanka-exporter/workflow.libsonnet').manifest(),
}
