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

local commentManifester = {
  overrideManifest(): {
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

  addBlockComment(needle, comment): {
    commenter+:
      commenter.addCommentBeforeLine(needle, comment),
  },
};

ga
+ {
  workflow+: {
    local this = self,

    new(slug, name=slug):
      super.new(name)
      + self.withSlug(slug)
      + commentManifester.overrideManifest(),

    withSlug(slug): {
      type:: 'workflow',
      metadata+:: {
        slug: slug,
        filename: 'workflows/' + slug + '.yaml',
      },
      on+: (
        ga.workflow.on.push.withPathsMixin('.github/' + self.metadata.filename)
        + ga.workflow.on.pull_request.withPathsMixin('.github/' + self.metadata.filename)
      ).on,
    },

    addComment(needle, comment): commentManifester.addComment(needle, comment),
    addBlockComment(needle, comment): commentManifester.addBlockComment(needle, comment),

    // shortcut that manifests the needle as yaml
    addCommentForObj(obj, comment):
      self.addComment(std.manifestYamlDoc(obj, quote_keys=false), comment),
    addBlockCommentForObj(obj, comment):
      self.addBlockComment(std.manifestYamlDoc(obj, quote_keys=false), comment),

    permissions+: {
      addWithComment(permission, value, comment):
        this.withPermissionsMixin({ [permission]: value })
        + this.addCommentForObj({ [permission]: value }, comment),
    },
  },

  action+: {
    composite+: {
      new(slug, name=slug, description=name):
        super.new(name, description)
        + self.withSlug(slug)
        + commentManifester.overrideManifest(),

      withSlug(slug): {
        type:: 'action',
        metadata+:: {
          slug: slug,
          filename: 'actions/' + slug + '/action.yaml',
        },
      },

      addComment(needle, comment): commentManifester.addComment(needle, comment),
      addBlockComment(needle, comment): commentManifester.addBlockComment(needle, comment),
    },
  },
}
