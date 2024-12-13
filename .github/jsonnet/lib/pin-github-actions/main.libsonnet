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
  },

  latest(latestVersions): {
    local findLatestVersion(repo) =
      std.filter(
        function(s)
          s.repo == repo,
        latestVersions
      ),

    new(action, repo=action):
      local found = findLatestVersion(repo);
      local latest =
        if std.length(found) != 0
        then found[0]
        else { sha: 'TBD', tag: 'TBD' };
      root.new(action, latest.sha)
      + {
        repo: repo,
        tag: latest.tag,
      },
  },
}
