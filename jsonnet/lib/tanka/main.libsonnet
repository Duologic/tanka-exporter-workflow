local tk = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';

{
  environment: {
    new(app, namespace, resources): {
      app: app,
      namespace: namespace,
      resources: resources,

      env(cluster):
        tk.environment.new(
          std.join('/', [
            'environments',
            self.app,
            cluster.name,
            self.namespace,
          ]),
          self.namespace,
          cluster.apiServer
        )
        + tk.environment.withLabels({
          cluster_name: cluster.name,
        })
        + tk.environment.withData(self.resources),

      deploy(clusters): [
        self.env(cluster)
        for cluster in clusters
      ],
    },
  },
}
