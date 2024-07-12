local input = importstr '/dev/stdin';

local diffFiles = [
  std.split(line, '\t')
  for line in std.split(input, '\n')
  if line != ''
];

local deletedEnvs = [
  file[1]
  for file in diffFiles
  if file[0] == 'D'
  if std.startsWith(file[1], 'jsonnet/environments/')
  if std.endsWith(file[1], '/main.jsonnet')
];

local modifiedTankaFiles = [
  ((if file[0] == 'D' then 'deleted:' else '') + file[1])[8:]
  for file in diffFiles
  if std.startsWith(file[1], 'jsonnet/')
];

|||
  DELETED_ENVS=%s
  MODIFIED_ENVS=$(tk tool importers %s)
||| % [
  std.join('--merge-deleted-envs ', deletedEnvs),
  std.join(' ', modifiedTankaFiles),
]
