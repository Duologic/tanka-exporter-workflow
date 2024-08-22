{
  local root = self,

  new(action, version): {
    action: action,
    version: version,
    asUses():: self.action + '@' + self.version,
  },

  relative: {
    new(action): {
      assert std.startsWith(action, './') : 'Local actions need to start with `./`',
      action: action,
      asUses(checkoutPath='')::
        if checkoutPath == ''
        then self.action
        else
          './'
          + checkoutPath
          + (
            if std.endsWith(checkoutPath, '/')
            then ''
            else '/'
          )
          + self.action[2:],
    },

    fromFilename(filename)::
      self.new(
        filename[
          :std.length(filename) -
           if std.endsWith(filename, '/action.yaml')
           then std.length('/action.yaml')
           else if std.endsWith(filename, '/action.yml')
           then std.length('/action.yml')
           else error "Filename doesn't end with /action.yaml or /action.yml"
        ]
      ),
  },

  latest(latestVersions): {
    local findLatestVersion(repo) =
      std.filter(
        function(s)
          s.repo == repo,
        latestVersions
      )[0],

    new(action, repo=action):
      local latest = findLatestVersion(repo);
      root.new(action, latest.sha)
      + {
        repo: repo,
        tag: latest.tag,
      },
  },
}