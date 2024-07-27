local k = import 'k.libsonnet';
local clusters = import 'meta/clusters.libsonnet';
local namespaces = import 'meta/namespaces.libsonnet';
local tk = import 'tanka/main.libsonnet';

local app = 'namespaces';
local namespace = 'default';  // these are cluster-wide resources but Tanka requires a default namespace

local resources = [
  k.core.v1.namespace.new(namespace)
  for namespace in namespaces.all
];

tk.environment.new(app, namespace, resources).deploy(clusters)
