local manifest(arr) =
  {
    [obj.metadata.filename]:
      '# Generated, please do not edit.\n'
      + obj.manifest()
    for obj in arr
  };

manifest([
  (import './fetch/action.libsonnet'),
  (import './jrsonnet-install/action.libsonnet'),
  (import './tanka-install/action.libsonnet'),
  (import './tanka-exporter/action.libsonnet'),
  (import './tanka-exporter/workflow.libsonnet'),
])
