local common = import 'common/main.libsonnet';
local manifest(f) =
  '# Generated with `make gen`\n'
  + std.manifestYamlDoc(f, indent_array_in_object=true, quote_keys=false);
{
  'actions/jrsonnet-install/action.yaml': common.manifestAction(import './jrsonnet-install/action.libsonnet'),
  'actions/tanka-install/action.yaml': common.manifestAction(import './tanka-install/action.libsonnet'),
  'actions/tanka-exporter/action.yaml': common.manifestAction(import './tanka-exporter/action.libsonnet'),
  'workflows/tanka-exporter.yaml': manifest(import './tanka-exporter/workflow.libsonnet'),
}
