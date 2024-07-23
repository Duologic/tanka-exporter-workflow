local tk = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local k = import 'k.libsonnet';
local clusters = import 'meta/clusters.libsonnet';

local namespace = 'test';
local app = namespace;

local resources =
  k.apps.v1.deployment.new(
    'test-again',
    150,
    []
  );

[
  tk.environment.new(
    std.join('/', [
      'environments',
      app,
      cluster.name,
      namespace,
    ]),
    namespace,
    cluster.apiServer
  )
  + tk.environment.withLabels({
    cluster_name: cluster.name,
  })
  + tk.environment.withData(resources)
  for cluster in std.objectValuesAll(clusters)
]
