local manifest(f) =
  '# Generated with `make gen`\n'
  + std.manifestYamlDoc(f, indent_array_in_object=true, quote_keys=false);
{
  'tanka-exporter.yaml': manifest(import './tanka-exporter/main.libsonnet'),
}
