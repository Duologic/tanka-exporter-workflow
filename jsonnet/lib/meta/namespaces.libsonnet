local environments = import './environments.libsonnet';

{
  data:
    std.foldl(
      function(acc, env)
        acc + {
          [env.spec.namespace]+: {
            clusters+: [env.metadata.labels.cluster_name],
          },
        },
      environments.all,
      {},
    ),

  all: std.objectFields(self.data),
}
