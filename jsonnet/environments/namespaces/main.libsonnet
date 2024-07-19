local tk = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local k = import 'k.libsonnet';
local clusters = import 'meta/clusters.libsonnet';
local namespaces = import 'meta/namespaces.libsonnet';

local namespace = 'namespaces';
local app = namespace;

local resources = [
  k.core.v1.namespace.new(namespace)
  for namespace in namespaces.all
];

[
  tk.environment.new(app, namespace, cluster.apiServer)
  + tk.environment.withLabels({
    cluster_name: cluster.name,
  })
  + tk.environment.withData(resources)
  for cluster in std.objectValuesAll(clusters)
]
