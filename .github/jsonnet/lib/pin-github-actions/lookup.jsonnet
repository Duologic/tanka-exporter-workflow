function(input)
  std.join(
    ' ',
    std.set([
      action.value.repo
      for action in std.objectKeysValues(input)
      if 'repo' in action.value
    ])
  )
