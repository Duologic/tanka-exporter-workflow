local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';


local paths = [
  'jsonnet/**',
  '.github/**',
];

ga.workflow.on.push.withPaths(paths)
+ ga.workflow.on.push.withBranches(['main'])
+ ga.workflow.on.pull_request.withPaths(paths)
+ ga.workflow.on.withWorkflowDispatch({})
+ ga.workflow.permissions.withPullRequests('write')  // allow pr comments
+ ga.workflow.permissions.withContents('write')  // allow git push
+ ga.workflow.concurrency.withGroup('${{ github.workflow }}-${{ github.ref }}')  // only run this workflow once per ref
+ ga.workflow.concurrency.withCancelInProgress("${{ github.ref != 'master' }}")  // replace concurrent runs in PRs
+ ga.workflow.withJobs({
  export:
    local sourceRepo = '_source';
    local jsonnetDir = 'jsonnet';
    local manifestsRepo = '_manifests';

    ga.job.withRunsOn('ubuntu-latest')
    + ga.job.withSteps([
      ga.job.step.withName('Checkout source repository')
      + ga.job.step.withUses('actions/checkout@v4')
      + ga.job.step.withWith({ path: sourceRepo }),

      ga.job.step.withName('Checkout manifest repository')
      + ga.job.step.withUses('actions/checkout@v4')
      + ga.job.step.withWith({
        ref: 'main',
        path: manifestsRepo,
      }),

      ga.job.step.withUses(sourceRepo + '/.github/actions/install-tanka'),
      ga.job.step.withUses('kobtea/setup-jsonnet-action@v2'),

      ga.job.step.withName('Find changed paths')
      + ga.job.step.withId('filter')
      + ga.job.step.withUses('dorny/paths-filter@v3')
      + ga.job.step.withWith({
        'working-directory': sourceRepo,
        'list-files': 'json',
        // multiline ||| triggers multiline in manifestYamlDoc
        filters: |||
          %s
        ||| % std.manifestYamlDoc({
          jsonnet: [jsonnetDir + '/**'],
          addedModifiedJsonnet: [{ 'added|modified': jsonnetDir + '/**' }],
          deletedJsonnet: [{ deleted: jsonnetDir + '/**' }],
          deletedEnvs: [{ deleted: jsonnetDir + '/environments/**/main.jsonnet' }],
        }, true),
      }),

      ga.job.step.withName('Find modified Tanka environments')
      + ga.job.step.withId('modified')
      + ga.job.step.withIf("${{ steps.filter.outputs.addedModifiedJsonnet == 'true' }}")
      + ga.job.step.withWorkingDirectory(sourceRepo + '/' + jsonnetDir)
      + ga.job.step.withRun(
        |||
          MODIFIED_FILES=$(jsonnet -S -e "$SCRIPT")
          MODIFIED_ENVS=$(tk tool importers $MODIFIED_FILES)
          if [[ -n ${MODIFIED_ENVS} ]]; then
              ARGS="$MODIFIED_ENVS --merge-strategy=replace-envs"
              echo "args=$ARGS" >> $GITHUB_OUTPUT
          fi
        |||
      )
      + ga.job.step.withEnv({
        SCRIPT: |||
          std.join(' ',
            std.map(function(f) f[%s:], ${{ steps.filter.outputs.addedModifiedJsonnet_files }})
            + std.map(function(f) 'deleted:'+f[%s:], ${{ steps.filter.outputs.deletedJsonnet_files }})
          )
        ||| % [std.length(jsonnetDir) + 1, std.length(jsonnetDir) + 1],
      }),

      ga.job.step.withName('Find deleted Tanka environments')
      + ga.job.step.withId('deleted')
      + ga.job.step.withIf("${{ steps.filter.outputs.deletedEnvs == 'true' }}")
      + ga.job.step.withRun(
        |||
          DELETED_ARGS=$(jsonnet -S -e "std.join('--merge-deleted-envs ', $DELETED_FILES)")
          echo "args=$DELETED_ARGS" >> $GITHUB_OUTPUT
        |||
      )
      + ga.job.step.withEnv({
        DELETED_FILES: '${{ steps.filter.outputs.deletedEnvs_files }}',
      }),

      ga.job.step.withName('Find out whether to do a bulk export')
      + ga.job.step.withId('bulk')
      + ga.job.step.withIf("${{ github.event_name == 'workflow_dispatch' }}")
      + ga.job.step.withRun(
        |||
          echo "bulk=true" >> $GITHUB_OUTPUT
          ARGS="environments/ --merge-strategy=fail-on-conflicts"
          echo "args=$ARGS" >> $GITHUB_OUTPUT
        |||
      ),

      ga.job.step.withName('Clear out manifests for bulk export')
      + ga.job.step.withIf("${{ steps.bulk.outputs.bulk == 'true' }}")
      + ga.job.step.withRun('rm -rf manifests/*/')
      + ga.job.step.withWorkingDirectory(manifestsRepo),

      ga.job.step.withName('Compose Tanka arguments')
      + ga.job.step.withId('args')
      + ga.job.step.withRun(
        |||
          if [ $BULK = 'true' ]; then
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
      + ga.job.step.withEnv({
        BULK: '${{ steps.bulk.outputs.bulk }}',
        BULK_ARGS: '${{ steps.bulk.outputs.args }}',

        MODIFIED_ARGS: '${{ steps.modified.outputs.args }}',
        DELETED_ARGS: '${{ steps.deleted.outputs.args }}',
      }),

      ga.job.step.withName('Export manifests with Tanka')
      + ga.job.step.withId('export')
      + ga.job.step.withIf("${{ steps.args.outputs.noop != 'true' }}")
      + ga.job.step.withWorkingDirectory(sourceRepo + '/' + jsonnetDir)
      + ga.job.step.withRun(
        |||
          tk export \
          ../$MANIFESTS_DIR/manifests/ \
          $ARGS \
          --recursive \
          --format '$EXPORT_FORMAT'
        |||
      )
      + ga.job.step.withEnv({
        ARGS: '${{ steps.args.outputs.args }}',
        MANIFESTS_DIR: manifestsRepo,
        EXPORT_FORMAT: std.strReplace(
          |||
            {{ if env.metadata.labels.cluster_name }}{{ env.metadata.labels.cluster_name }}/{{ end }}
            {{ if .metadata.namespace }}{{.metadata.namespace}}
            {{ else }}_cluster
            {{ end }}/
            {{.kind}}-{{.metadata.name}}
          |||,
          '\n',
          ''
        ),
      }),

      ga.job.step.withName('Check if manifests changed')
      + ga.job.step.withId('changed')
      + ga.job.step.withUses('tj-actions/verify-changed-files@v20')
      + ga.job.step.withWith({
        files: 'manifests/**',
        path: manifestsRepo,
      }),

      ga.job.step.withName('Check out branch for pull_request commit')
      + ga.job.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed == 'true' }}")
      + ga.job.step.withWorkingDirectory(manifestsRepo)
      + ga.job.step.withRun('git checkout -b pr-$PR')
      + ga.job.step.withEnv({ PR: '${{ github.event.number }}' }),

      ga.job.step.withName('Make a commit to the manifests repository')
      + ga.job.step.withId('commit')
      + ga.job.step.withIf("${{ steps.changed.outputs.files_changed == 'true' }}")
      + ga.job.step.withWorkingDirectory(manifestsRepo)
      + ga.job.step.withRun(
        |||
          git add manifests/
          git commit -m "$(git -C ../ show -s --format=%B)$MESSAGE"
          git log -1 --format=fuller
          git config --global push.autoSetupRemote true
          echo "sha=$(git rev-parse HEAD)" >> $GITHUB_OUTPUT
        |||
      )
      + ga.job.step.withEnv({
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

      ga.job.step.withName('Force push on pull_request')
      + ga.job.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed == 'true' }}")
      + ga.job.step.withWorkingDirectory(manifestsRepo)
      + ga.job.step.withRun('git push -u -f origin pr-$PR')
      + ga.job.step.withEnv({ PR: '${{ github.event.number }}' }),

      ga.job.step.withName('Push on main')
      + ga.job.withIf("${{ github.event_name == 'push' && github.ref == 'refs/heads/main' && steps.changed.outputs.files_changed == 'true' }}")
      + ga.job.step.withWorkingDirectory(manifestsRepo)
      + ga.job.step.withRun('git push'),

      ga.job.step.withName('Make no-op comment')
      + ga.job.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed != 'true' }}")
      + ga.job.step.withUses('thollander/actions-comment-pull-request@v2')
      + ga.job.step.withWith({
        message: 'No changes',
        comment_tag: '${{ github.workflow }}-difflinks',
        mode: 'recreate',
      }),

      ga.job.step.withName('Make changes comment')
      + ga.job.withIf("${{ github.event_name == 'pull_request' && steps.changed.outputs.files_changed == 'true' }}")
      + ga.job.step.withUses('thollander/actions-comment-pull-request@v2')
      + ga.job.step.withWith({
        message: |||
          permalink: ${{ github.server_url }}/${{ github.repository }}/compare/${{ github.event.pull_request.base.sha }}...${{ steps.commit.outputs.sha }}
          relative: ${{ github.server_url }}/${{ github.repository }}/compare/main...pr-${{ github.event.number }}
        |||,
        comment_tag: '${{ github.workflow }}-difflinks',
        mode: 'recreate',
      }),
    ]),
})
