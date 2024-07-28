local tk = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local fluxcd = import 'github.com/jsonnet-libs/fluxcd-libsonnet/2.3.0/main.libsonnet';
local kustomization = fluxcd.kustomize.v1.kustomization;

// Hardcoded but should be ref on the flux-system deployment
local source =
  fluxcd.source.v1.gitRepository.new('tanka-exporter-workflow')
  + fluxcd.source.v1.gitRepository.metadata.withNamespace('flux-system');

{
  environment: {
    new(app, namespace, resources): {
      local this = self,
      app: app,
      namespace: namespace,
      resources: resources,

      name(cluster, sep):
        std.join(sep, [
          this.app,
          cluster.name,
          this.namespace,
        ]),

      kustomization(cluster):
        kustomization.new(this.name(cluster, '-'))
        + kustomization.spec.sourceRef.withKind(source.kind)
        + kustomization.spec.sourceRef.withName(source.metadata.name)
        + kustomization.spec.sourceRef.withNamespace(source.metadata.namespace)
        + kustomization.spec.withInterval('1m0s')
        + kustomization.spec.withRetryInterval('15s')
        + kustomization.spec.withPath('manifests/' + this.name(cluster, '/')),

      env(cluster):
        tk.environment.new(
          this.name(cluster, '/'),
          this.namespace,
          cluster.apiServer
        )
        + tk.environment.withLabels({
          cluster: cluster.name,
          app: this.app,
        })
        + tk.environment.withData({
          kustomization: this.kustomization(cluster),
          resources: this.resources,
        }),

      deploy(clusters): [
        this.env(cluster)
        for cluster in clusters
      ],
    },
  },
}
