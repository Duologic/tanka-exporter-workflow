local k = import 'k.libsonnet';
local clusters = import 'meta/clusters.libsonnet';
local tk = import 'tanka/main.libsonnet';

local namespace = 'test';
local app = namespace;

local resources =
  k.apps.v1.deployment.new(
    'test-again',
    350,
    []
  ) + { spec+: { template+: { spec+: { containers: 'invalid string' } } } };

tk.environment.new(app, namespace, resources).deploy(clusters)
