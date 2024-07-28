local k = import 'k.libsonnet';
local clusters = import 'meta/clusters.libsonnet';
local tk = import 'tanka/main.libsonnet';

local namespace = 'test';
local app = 'test_duplicate';

local resources =
  k.apps.v1.deployment.new(
    'test-again',
    150,
    []
  );

tk.environment.new(app, namespace, resources).deploy(clusters)
