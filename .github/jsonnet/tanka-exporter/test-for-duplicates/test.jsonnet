local resources = import './resources.jsonnet';
[
  std.foldl(
    function(acc, resource)
      acc +
      assert
        std.filter(
          function(r)
            r.kind == resource.kind
            && r.apiVersion == resource.apiVersion
            && r.metadata.name == resource.metadata.name
            && std.get(r.metadata, 'namespace') == std.get(resource.metadata, 'namespace')
          , acc
        ) == []
        : 'Duplicate resource found: \n'
          + std.manifestJson({
            kind: resource.kind,
            apiVersion: resource.apiVersion,
            metadata: {
              name: resource.metadata.name,
              [if 'namespace' in resource.metadata then 'namespace']: std.get(resource.metadata, 'namespace'),
            },
          });
      [resource],
    resources[cluster],
    []
  )
  for cluster in std.objectFields(resources)
]
