function(input)
  local importstrs = input;
  local all = std.join('\n', importstrs);

  local usesLines =
    std.set(
      std.map(
        function(line)
          std.lstripChars(line, ' -'),
        std.filter(function(s) std.length(std.findSubstr('uses:', s)) > 0, std.split(all, '\n'))
      )
    );

  local imports = std.map(std.parseYaml, importstrs);

  local workflows =
    std.filter(
      function(i)
        'jobs' in i,
      imports
    );

  local actions =
    std.filter(
      function(i)
        'runs' in i
        && i.runs.using == 'composite',
      imports
    );

  local getUsesFromSteps(steps) =
    std.filterMap(
      function(s)
        'uses' in s,
      function(s)
        s.uses,
      steps
    );

  local getUsesFromWorkflow(workflow) =
    std.set(
      std.foldl(
        function(acc, job)
          acc + getUsesFromSteps(std.get(job, 'steps', [])),
        std.objectValues(workflow.jobs),
        [],
      )
    );

  local getUsesFromAction(action) =
    std.set(
      getUsesFromSteps(action.runs.steps)
    );

  local used = std.set(
    std.foldl(
      function(acc, workflow)
        acc + getUsesFromWorkflow(workflow),
      workflows,
      []
    )
    + std.foldl(
      function(acc, action)
        acc + getUsesFromAction(action),
      actions,
      []
    )
  );

  local parse(action) =
    assert !std.startsWith(action, './') : 'local action';
    local versionSplit = std.splitLimitR(action, '@', 1);
    local repoSplit = std.splitLimitR(versionSplit[0], '/', 2);
    local lines =
      std.set(
        std.filter(
          function(line)
            std.length(std.findSubstr('#', line)) > 0
            && std.length(std.findSubstr(action, line)) > 0,
          usesLines
        )
      );
    assert std.length(lines) == 0 || std.length(lines) == 1 : 'Multiple lines match: ' + std.manifestJson(lines);
    {
      action: versionSplit[0],
      version: versionSplit[1],

      // only include repo if tagged
      repo: repoSplit[0] + '/' + repoSplit[1],
      //[if std.length(lines) > 0 then 'repo']: repoSplit[0] + '/' + repoSplit[1],
      [if std.length(lines) > 0 then 'tag']: std.split(lines[0], ' # ')[1],

      asUses():: action,
    };

  local result =
    std.filterMap(
      function(a) !std.startsWith(a, './'),
      parse,
      used
    );

  {
    [k.action]: k
    for k in result
  }
