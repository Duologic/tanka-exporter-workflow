local tk = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';

{
  environment: {
    new(app, namespace, resources): {
      local this = self,
      app: app,
      namespace: namespace,
      resources: resources,

      env(cluster):
        tk.environment.new(
          std.join('/', [
            this.app,
            cluster.name,
            this.namespace,
          ]),
          this.namespace,
          cluster.apiServer
        )
        + tk.environment.withLabels({
          cluster: cluster.name,
          app: this.app,
        })
        + tk.environment.withData(this.resources),

      deploy(clusters): [
        this.env(cluster)
        for cluster in clusters
      ],
    },
  },
}
