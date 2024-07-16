local manifest(f) =
  '# Generated with `make gen`\n'
  + std.manifestYamlDoc(f, indent_array_in_object=true, quote_keys=false);
{
  'actions/tanka-install/action.yaml': manifest(import './tanka-install/action.libsonnet'),
  'actions/tanka-exporter/action.yaml': manifest(import './tanka-exporter/action.libsonnet'),
  'workflows/tanka-exporter.yaml': manifest(import './tanka-exporter/workflow.libsonnet'),
}
