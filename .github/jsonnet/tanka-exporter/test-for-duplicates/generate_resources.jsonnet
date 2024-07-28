local manifests = import 'manifests.json';

local grouped = std.foldl(
  function(acc, path)
    acc + {
      [std.split(path, '/')[1]]+: [
        path,
      ],
    },
  std.objectFields(manifests),
  {}
);

'{\n'
+ std.join('\n', [
  ('  "%s": [\n' % cluster)
  + std.join('\n', [
    '    std.parseYaml(importstr "%s"),' % path
    for path in grouped[cluster]
  ])
  + '\n  ],'
  for cluster in std.objectFields(grouped)
])
+ '\n}'
