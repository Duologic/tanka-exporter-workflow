local manifest(f) =
  '# Generated with `make gen`\n'
  + std.manifestYamlDoc(f, indent_array_in_object=true, quote_keys=false);
{
  'workflows/tanka-exporter.yaml': manifest(import './tanka-exporter/main.libsonnet'),
  'actions/tanka-install/action.yaml': manifest(import './tanka-install/main.libsonnet'),
  'actions/tanka-exporter/action.yaml': manifest(import './tanka-exporter/action.libsonnet'),
}
