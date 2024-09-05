local commenter = import './main.libsonnet';

local c =
  commenter.new(
    |||
      {
        person1: {
          name: "Alice",
          welcome: "Hello " + self.name + "!",
        },
        person2: self.person1 { name: "Bob" },
      }
    |||
  )
  + commenter.addComment('person1:', 'description of person 1');

c.apply()
