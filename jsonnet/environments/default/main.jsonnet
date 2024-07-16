local k = import 'k.libsonnet';

k.apps.v1.deployment.new(
  'test-again',
  150,
  []
)
