local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';
local gac = ga.action.composite;
local step = gac.runs.step;

local common = import 'common/main.libsonnet';

local actionCheckoutPath = '_tanka-exporter-checkout';

local targetRepoPath = '${{ github.workspace }}/${{ inputs.target-repository }}';
local targetDirPath = targetRepoPath + '/${{ inputs.target-directory }}';
local sourceRepoPath = '${{ github.workspace }}/${{ inputs.source-repository }}';
local tankaRootPath = sourceRepoPath + '/${{ inputs.tanka-root }}';

gac.new('Export Tanka environments')
+ gac.withInputs({
  'source-repository':
    gac.input.withDescription('Path to source repository relative to the workspace')
    + gac.input.withRequired(),
  'tanka-root':
    gac.input.withDescription('Tanka root relative to the source-repository')
    + gac.input.withRequired(),
  'target-repository':
    gac.input.withDescription('Path to target repository relative to the workspace')
    + gac.input.withRequired(),
  'target-directory':
    gac.input.withDescription('Directory for the manifests in the target-repository')
    + gac.input.withRequired(),
})
+ gac.withOutputs({
  files_changed:
    gac.withDescription("Return 'true' when files have changed on the target repository")
    + gac.output.withValue('${{ steps.changed.outputs.files_changed }}'),
  changed_files:
    gac.withDescription('List of files changed on the target repository')
    + gac.output.withValue('${{ steps.changed.outputs.changed_files }}'),
  commit_sha:
    gac.withDescription('Commit sha on the target repository')
    + gac.output.withValue('${{ steps.commit.outputs.sha }}'),
})
+ gac.runs.withSteps([
  common.actionRepo.checkoutStep(actionCheckoutPath),

  step.withName('Install Tanka')
  + step.withUses('./%s/.github/actions/tanka-install' % actionCheckoutPath),

  step.withName('Install jrsonnet')
  + step.withUses('./%s/.github/actions/jrsonnet-install' % actionCheckoutPath),

  step.withName('Install Jsonnet')
  + step.withUses('kobtea/setup-jsonnet-action@v2'),

  step.withName('Find changed paths')
  + step.withId('filter')
  + step.withUses('dorny/paths-filter@v3')
  + step.withWith({
    'working-directory': '${{ inputs.source-repository }}',
    'list-files': 'json',
    // multiline ||| triggers multiline in std.manifestYamlDoc
    filters: |||
      %s
    ||| % std.manifestYamlDoc({
      jsonnet: ['${{ inputs.tanka-root }}/**'],
      addedModifiedJsonnet: [{ 'added|modified': '${{ inputs.tanka-root }}/**' }],
      deletedJsonnet: [{ deleted: '${{ inputs.tanka-root }}/**' }],
      deletedEnvs: [{ deleted: '${{ inputs.tanka-root }}/environments/**/main.jsonnet' }],
    }, true),
  }),

  step.withName('Find modified Tanka environments')
  + step.withId('modified')
  + step.withIf("${{ steps.filter.outputs.addedModifiedJsonnet == 'true' }}")
  + step.withWorkingDirectory(tankaRootPath)
  + step.withShell('bash')
  + step.withRun(
    |||
      MODIFIED_FILES=$(jrsonnet -S -e "$SCRIPT")
      MODIFIED_ENVS=$(tk tool importers $MODIFIED_FILES | tr '\n' ' ')
      if [[ -n ${MODIFIED_ENVS} ]]; then
          ARGS="$MODIFIED_ENVS --merge-strategy=replace-envs"
          echo "args=$ARGS" >> $GITHUB_OUTPUT
      fi
    |||
  )
  + step.withEnv({
    SCRIPT: |||
      local prefixLength = std.length('${{ inputs.tanka-root }}/');
      std.join(' ',
        std.map(function(f) f[prefixLength:], ${{ steps.filter.outputs.addedModifiedJsonnet_files }})
        + std.map(function(f) 'deleted:'+f[prefixLength:], ${{ steps.filter.outputs.deletedJsonnet_files }})
      )
    |||,
  }),

  step.withName('Find deleted Tanka environments')
  + step.withId('deleted')
  + step.withIf("${{ steps.filter.outputs.deletedEnvs == 'true' }}")
  + step.withShell('bash')
  + step.withRun(
    |||
      DELETED_ARGS=$(jrsonnet -S -e "std.join('--merge-deleted-envs ', $DELETED_FILES)")
      echo "args=$DELETED_ARGS" >> $GITHUB_OUTPUT
    |||
  )
  + step.withEnv({
    DELETED_FILES: '${{ steps.filter.outputs.deletedEnvs_files }}',
  }),

  step.withName('Find out whether to do a bulk export')
  + step.withId('bulk')
  // FIXME: The bulk exporter should also run as a cron to detect drift on main pushes
  + step.withIf("${{ github.event_name == 'workflow_dispatch' }}")
  + step.withShell('bash')
  + step.withRun(
    |||
      echo "bulk=true" >> $GITHUB_OUTPUT
      ARGS="environments/ --merge-strategy=fail-on-conflicts"
      echo "args=$ARGS" >> $GITHUB_OUTPUT
    |||
  ),

  step.withName('Clear out manifests for bulk export')
  + step.withIf("${{ steps.bulk.outputs.bulk == 'true' }}")
  + step.withWorkingDirectory(targetRepoPath)
  + step.withShell('bash')
  + step.withRun('rm -rf $MANIFESTS_DIR/*')
  + step.withEnv({
    MANIFESTS_DIR: '${{ inputs.target-directory }}',
  }),

  step.withName('Compose Tanka arguments')
  + step.withId('args')
  + step.withShell('bash')
  + step.withRun(
    |||
      if [[ $BULK = 'true' ]]; then
          ARGS="$BULK_ARGS"
          echo "args=$ARGS" >> $GITHUB_OUTPUT
      elif [[ -n $MODIFIED_ARGS || -n $DELETED_ARGS ]]; then
          ARGS="$MODIFIED_ARGS $DELETED_ARGS"
          echo "args=$ARGS" >> $GITHUB_OUTPUT
      else
          echo "noop=true" >> $GITHUB_OUTPUT
      fi
    |||
  )
  + step.withEnv({
    BULK: '${{ steps.bulk.outputs.bulk }}',
    BULK_ARGS: '${{ steps.bulk.outputs.args }}',

    MODIFIED_ARGS: '${{ steps.modified.outputs.args }}',
    DELETED_ARGS: '${{ steps.deleted.outputs.args }}',
  }),

  step.withName('Export manifests with Tanka')
  + step.withId('export')
  + step.withIf("${{ steps.args.outputs.noop != 'true' }}")
  + step.withWorkingDirectory(tankaRootPath)
  + step.withShell('bash')
  + step.withRun(
    |||
      tk export \
      $EXPORT_DIR \
      $ARGS \
      --recursive \
      --format "$EXPORT_FORMAT"
    |||
  )
  + step.withEnv({
    ARGS: '${{ steps.args.outputs.args }}',
    EXPORT_DIR: targetDirPath,
    EXPORT_FORMAT: std.join('/', [
      '{{ env.metadata.labels.app }}',
      '{{ env.metadata.labels.cluster }}',
      '{{ env.spec.namespace }}',
      '{{ .kind }}-{{ .metadata.name }}',
    ]),
  }),

  step.withName('Check for duplicate resources in cluster')
  + step.withIf("${{ steps.args.outputs.noop != 'true' }}")
  + step.withWorkingDirectory(targetDirPath)
  + step.withShell('bash')
  + step.withRun(|||
    cat manifest.json
    jrsonnet -S "$SCRIPT_PATH"/generate_resources.jsonnet > resources.jsonnet
    jrsonnet "$SCRIPT_PATH"/test_for_duplicate_resources.jsonnet
    rm resources.jsonnet
  |||)
  + step.withEnv({
    SCRIPT_PATH: './%s/.github/actions/tanka-exporter/scripts' % actionCheckoutPath,
  }),

  step.withName('Check if manifests changed')
  + step.withId('changed')
  + step.withUses('tj-actions/verify-changed-files@v20')
  + step.withWith({
    path: '${{ inputs.target-repository }}',
  }),

  step.withName('Check out branch for pull_request commit')
  + step.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed == 'true' }}")
  + step.withWorkingDirectory(targetRepoPath)
  + step.withShell('bash')
  + step.withRun('git checkout -b pr-$PR')
  + step.withEnv({ PR: '${{ github.event.number }}' }),

  step.withName('Make a commit to the manifests repository')
  + step.withId('commit')
  + step.withIf("${{ steps.changed.outputs.files_changed == 'true' }}")
  + step.withWorkingDirectory(targetRepoPath)
  + step.withShell('bash')
  + step.withRun(
    |||
      git add $MANIFESTS_DIR
      git commit -m "$(git -C $SOURCE_REPO show -s --format=%B)$MESSAGE"
      git log -1 --format=fuller
      git config --global push.autoSetupRemote true
      echo "sha=$(git rev-parse HEAD)" >> $GITHUB_OUTPUT
    |||
  )
  + step.withEnv({
    MANIFESTS_DIR: '${{ inputs.target-directory }}',
    SOURCE_REPO: sourceRepoPath,
    GIT_AUTHOR_NAME: '${{ github.actor }}',
    GIT_AUTHOR_EMAIL: '${{ github.actor_id }}+${{ github.actor }}@users.noreply.github.com',
    GIT_COMMITTER_NAME: 'github-actions[bot]',
    GIT_COMMITTER_EMAIL: '41898282+github-actions[bot]@users.noreply.github.com',

    MESSAGE: |||

      --

      - Event: ${{ github.event_name }}
      - Branch: ${{ github.base_ref }}
      - Build link: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
    |||,
  }),

  step.withName('Force push on pull_request')
  + step.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed == 'true' }}")
  + step.withWorkingDirectory(targetRepoPath)
  + step.withShell('bash')
  + step.withRun('git push -u -f origin pr-$PR')
  + step.withEnv({ PR: '${{ github.event.number }}' }),

  step.withName('Push on main')
  + step.withIf("${{ (github.event_name == 'push' || github.event_name == 'workflow_dispatch') && github.ref == 'refs/heads/main' && steps.changed.outputs.files_changed == 'true' }}")
  + step.withWorkingDirectory(targetRepoPath)
  + step.withShell('bash')
  + step.withRun('git push'),

  step.withName('Make no-op comment')
  + step.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed != 'true' }}")
  + step.withUses('thollander/actions-comment-pull-request@v2')
  + step.withWith({
    message: 'No changes',
    comment_tag: '${{ github.workflow }}-difflinks',
    mode: 'recreate',
  }),

  step.withName('Make changes comment')
  + step.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed == 'true' }}")
  + step.withUses('thollander/actions-comment-pull-request@v2')
  + step.withWith({
    message: |||
      permalink: ${{ github.server_url }}/${{ github.repository }}/compare/${{ github.event.pull_request.base.sha }}...${{ steps.commit.outputs.sha }}
      relative: ${{ github.server_url }}/${{ github.repository }}/compare/main...pr-${{ github.event.number }}
    |||,
    comment_tag: '${{ github.workflow }}-difflinks',
    mode: 'recreate',
  }),
])
