local actions = import 'common/actions.libsonnet';
local commenter = import 'github.com/Duologic/commenter-libsonnet/main.libsonnet';
local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';

local commentsPinnedVersions = [
  commenter.comment.new(
    'uses: ' + action.value.asUses(),
    action.value.tag
  )
  + commenter.comment.onSameLine()
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
        commenter.addCommentOnSameLine(needle, comment),
    },

    addLongComment(needle, comment): {
      commenter+:
        commenter.addCommentBeforeLine(needle, comment),
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
          commenter.addCommentOnSameLine(needle, comment),
      },

      addLongComment(needle, comment): {
        commenter+:
          commenter.addCommentBeforeLine(needle, comment),
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
