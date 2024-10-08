local commenter = import 'commenter/main.libsonnet';
local actions = import 'common/actions.libsonnet';
local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local commentsPinnedVersions = [
  action.value.comment
  for action in std.objectKeysValues(actions)
  if 'repo' in action.value
];

ga
+ {
  workflow+: {
    new(slug, name=slug):
      super.new(name)
      + self.withSlug(slug)
      + {
        commenter::
          commenter.new(super.manifest())
          + { comments: commentsPinnedVersions },

        manifest()::
          self.commenter.apply(),
      },
    addComment(needle, comment): {
      commenter+:
        commenter.addComment(needle, comment),
    },

    withSlug(slug): {
      type:: 'workflow',
      metadata+:: {
        slug: slug,
        filename: 'workflows/' + slug + '.yaml',
      },
    },
  },

  action+: {
    composite+: {
      new(slug, name=slug, description=name):
        super.new(name, description)
        + self.withSlug(slug)
        + {
          commenter::
            commenter.new(super.manifest())
            + { comments: commentsPinnedVersions },

          manifest()::
            self.commenter.apply(),
        },

      addComment(needle, comment): {
        commenter+:
          commenter.addComment(needle, comment),
      },

      withSlug(slug): {
        type:: 'action',
        metadata+:: {
          slug: slug,
          filename: 'actions/' + slug + '/action.yaml',
        },
      },
    },
  },
}
