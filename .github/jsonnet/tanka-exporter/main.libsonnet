local ga = import 'github.com/crdsonnet/github-actions-libsonnet/main.libsonnet';


local exportFormat = std.strReplace(
  |||
    {{ if env.metadata.labels.cluster_name }}{{ env.metadata.labels.cluster_name }}/{{ end }}
    {{ if .metadata.namespace }}{{.metadata.namespace}}
    {{ else }}_cluster
    {{ end }}/
    {{.kind}}-{{.metadata.name}}
  |||,
  '\n',
  ''
);

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
    ga.job.withRunsOn('ubuntu-latest')
    + ga.job.withSteps([
      ga.job.step.withUses('actions/checkout@v4')
      + ga.job.step.withWith({
        ref: '${{ github.event.pull_request.head.sha }}',
        'fetch-depth': 100,
      }),

      ga.job.step.withUses('actions/checkout@v4')
      + ga.job.step.withWith({
        ref: 'main',
        path: '_manifests',
      }),

      ga.job.step.withUses('./.github/actions/install-tanka'),

      ga.job.step.withId('filter')
      + ga.job.step.withUses('dorny/paths-filter@v3')
      + ga.job.step.withWith({
        // multiline ||| triggers multiline in manifestYamlDoc
        filters: |||
          %s
        ||| % std.manifestYamlDoc({ jsonnet: ['jsonnet/**'] }, true),
      }),

      ga.job.step.withRun('echo $OUTPUT')
      + ga.job.step.withEnv({
        OUTPUT: |||
          ${{ steps.fitler.outputs.changes }}
          ${{ steps.fitler.outputs.jsonnet }}
          ${{ steps.fitler.outputs.jsonnet_files }}
        |||,
      }),

      ga.job.withIf("${{ github.event_name == 'workflow_dispatch' }}")
      + ga.job.step.withRun('rm -rf manifests/*/')
      + ga.job.step.withWorkingDirectory('_manifests'),

      ga.job.step.withId('base')
      + ga.job.step.withRun(
        |||
          if [ $EVENT = 'pull_request' ]; then
              echo "base=$BASE_SHA" >> $GITHUB_OUTPUT
          else
              echo "base=$BEFORE" >> $GITHUB_OUTPUT
          fi
        |||
      )
      + ga.job.step.withEnv({
        BEFORE: '${{ github.event.before }}',
        BASE_SHA: '${{ github.event.pull_request.base.sha }}',
        EVENT: '${{ github.event_name }}',
      }),

      ga.job.step.withId('diff')
      + ga.job.step.withRun(
        |||
          if [ $BULK = 'true' ]; then
              echo "run as bulk"
              echo "doExport=true" >> $GITHUB_OUTPUT
          elif [[ -n $(git diff --name-status --no-renames $BASE...HEAD jsonnet/) ]]; then
              echo "changes found"
              echo "doExport=true" >> $GITHUB_OUTPUT
          fi
        |||
      )
      + ga.job.step.withEnv({
        BASE: '${{ steps.base.outputs.base }}',
        BULK: "${{ github.event_name == 'workflow_dispatch' }}",
      }),

      ga.job.step.withId('export')
      + ga.job.step.withIf("${{ steps.diff.outputs.doExport == 'true' }}")
      + ga.job.step.withWorkingDirectory('jsonnet')
      + ga.job.step.withRun(
        |||
          if [[ $BULK = 'true' ]]; then
            ARGS="environments/ --merge-strategy=fail-on-conflicts"
          else
            eval $(git diff --name-status --no-renames $BASE...HEAD | tk eval ../.github/jsonnet/env_partial_exporter.jsonnet | xargs printf)
            ARGS="$MODIFIED_ENVS --merge-strategy=replace-envs $DELETED_ENVS"
          fi

          echo $ARGS

          tk export \
          ../_manifests/manifests/ \
          $ARGS \
          --recursive \
          --format '%s'

          cd ../_manifests/manifests
          if [[ -n $(git status --porcelain .) ]]; then
              echo "changes found"
              git status .
              echo "changes=true" >> $GITHUB_OUTPUT
          fi
        ||| % exportFormat
      )
      + ga.job.step.withEnv({
        BASE: '${{ steps.base.outputs.base }}',
        BULK: "${{ github.event_name == 'workflow_dispatch' }}",
      }),

      ga.job.withIf("${{ github.event_name == 'pull_request' }}")
      + ga.job.step.withWorkingDirectory('_manifests')
      + ga.job.step.withRun('git checkout -b pr-$PR')
      + ga.job.step.withEnv({ PR: '${{ github.event.number }}' }),

      ga.job.step.withId('commit')
      + ga.job.step.withIf("${{ steps.export.outputs.changes == 'true' }}")
      + ga.job.step.withWorkingDirectory('_manifests')
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

      ga.job.withIf("${{ github.event_name == 'pull_request' && steps.export.outputs.changes == 'true' }}")
      + ga.job.step.withWorkingDirectory('_manifests')
      + ga.job.step.withRun('git push -u -f origin pr-$PR')
      + ga.job.step.withEnv({ PR: '${{ github.event.number }}' }),

      ga.job.withIf("${{ github.event_name == 'push' && github.ref == 'refs/heads/main' && steps.export.outputs.changes == 'true' }}")
      + ga.job.step.withWorkingDirectory('_manifests')
      + ga.job.step.withRun('git push'),

      ga.job.withIf("${{ github.event_name == 'pull_request' && steps.export.outputs.changes != 'true' }}")
      + ga.job.step.withUses('thollander/actions-comment-pull-request@v2')
      + ga.job.step.withWith({
        message: 'No changes',
        comment_tag: '${{ github.workflow }}-difflinks',
        mode: 'recreate',
      }),

      ga.job.withIf("${{ github.event_name == 'pull_request' && steps.export.outputs.changes == 'true' }}")
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
