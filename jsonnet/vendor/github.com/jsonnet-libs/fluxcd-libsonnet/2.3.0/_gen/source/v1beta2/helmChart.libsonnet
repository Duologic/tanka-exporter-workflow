{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='helmChart', url='', help='"HelmChart is the Schema for the helmcharts API."'),
  '#metadata':: d.obj(help='"ObjectMeta is metadata that all persisted resources must have, which includes all objects users must create."'),
  metadata: {
    '#withAnnotations':: d.fn(help='"Annotations is an unstructured key value map stored with a resource that may be set by external tools to store and retrieve arbitrary metadata. They are not queryable and should be preserved when modifying objects. More info: http://kubernetes.io/docs/user-guide/annotations"', args=[d.arg(name='annotations', type=d.T.object)]),
    withAnnotations(annotations): { metadata+: { annotations: annotations } },
    '#withAnnotationsMixin':: d.fn(help='"Annotations is an unstructured key value map stored with a resource that may be set by external tools to store and retrieve arbitrary metadata. They are not queryable and should be preserved when modifying objects. More info: http://kubernetes.io/docs/user-guide/annotations"\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='annotations', type=d.T.object)]),
    withAnnotationsMixin(annotations): { metadata+: { annotations+: annotations } },
    '#withClusterName':: d.fn(help='"The name of the cluster which the object belongs to. This is used to distinguish resources with same name and namespace in different clusters. This field is not set anywhere right now and apiserver is going to ignore it if set in create or update request."', args=[d.arg(name='clusterName', type=d.T.string)]),
    withClusterName(clusterName): { metadata+: { clusterName: clusterName } },
    '#withCreationTimestamp':: d.fn(help='"Time is a wrapper around time.Time which supports correct marshaling to YAML and JSON.  Wrappers are provided for many of the factory methods that the time package offers."', args=[d.arg(name='creationTimestamp', type=d.T.string)]),
    withCreationTimestamp(creationTimestamp): { metadata+: { creationTimestamp: creationTimestamp } },
    '#withDeletionGracePeriodSeconds':: d.fn(help='"Number of seconds allowed for this object to gracefully terminate before it will be removed from the system. Only set when deletionTimestamp is also set. May only be shortened. Read-only."', args=[d.arg(name='deletionGracePeriodSeconds', type=d.T.integer)]),
    withDeletionGracePeriodSeconds(deletionGracePeriodSeconds): { metadata+: { deletionGracePeriodSeconds: deletionGracePeriodSeconds } },
    '#withDeletionTimestamp':: d.fn(help='"Time is a wrapper around time.Time which supports correct marshaling to YAML and JSON.  Wrappers are provided for many of the factory methods that the time package offers."', args=[d.arg(name='deletionTimestamp', type=d.T.string)]),
    withDeletionTimestamp(deletionTimestamp): { metadata+: { deletionTimestamp: deletionTimestamp } },
    '#withFinalizers':: d.fn(help='"Must be empty before the object is deleted from the registry. Each entry is an identifier for the responsible component that will remove the entry from the list. If the deletionTimestamp of the object is non-nil, entries in this list can only be removed. Finalizers may be processed and removed in any order.  Order is NOT enforced because it introduces significant risk of stuck finalizers. finalizers is a shared field, any actor with permission can reorder it. If the finalizer list is processed in order, then this can lead to a situation in which the component responsible for the first finalizer in the list is waiting for a signal (field value, external system, or other) produced by a component responsible for a finalizer later in the list, resulting in a deadlock. Without enforced ordering finalizers are free to order amongst themselves and are not vulnerable to ordering changes in the list."', args=[d.arg(name='finalizers', type=d.T.array)]),
    withFinalizers(finalizers): { metadata+: { finalizers: if std.isArray(v=finalizers) then finalizers else [finalizers] } },
    '#withFinalizersMixin':: d.fn(help='"Must be empty before the object is deleted from the registry. Each entry is an identifier for the responsible component that will remove the entry from the list. If the deletionTimestamp of the object is non-nil, entries in this list can only be removed. Finalizers may be processed and removed in any order.  Order is NOT enforced because it introduces significant risk of stuck finalizers. finalizers is a shared field, any actor with permission can reorder it. If the finalizer list is processed in order, then this can lead to a situation in which the component responsible for the first finalizer in the list is waiting for a signal (field value, external system, or other) produced by a component responsible for a finalizer later in the list, resulting in a deadlock. Without enforced ordering finalizers are free to order amongst themselves and are not vulnerable to ordering changes in the list."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='finalizers', type=d.T.array)]),
    withFinalizersMixin(finalizers): { metadata+: { finalizers+: if std.isArray(v=finalizers) then finalizers else [finalizers] } },
    '#withGenerateName':: d.fn(help='"GenerateName is an optional prefix, used by the server, to generate a unique name ONLY IF the Name field has not been provided. If this field is used, the name returned to the client will be different than the name passed. This value will also be combined with a unique suffix. The provided value has the same validation rules as the Name field, and may be truncated by the length of the suffix required to make the value unique on the server.\\n\\nIf this field is specified and the generated name exists, the server will NOT return a 409 - instead, it will either return 201 Created or 500 with Reason ServerTimeout indicating a unique name could not be found in the time allotted, and the client should retry (optionally after the time indicated in the Retry-After header).\\n\\nApplied only if Name is not specified. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#idempotency"', args=[d.arg(name='generateName', type=d.T.string)]),
    withGenerateName(generateName): { metadata+: { generateName: generateName } },
    '#withGeneration':: d.fn(help='"A sequence number representing a specific generation of the desired state. Populated by the system. Read-only."', args=[d.arg(name='generation', type=d.T.integer)]),
    withGeneration(generation): { metadata+: { generation: generation } },
    '#withLabels':: d.fn(help='"Map of string keys and values that can be used to organize and categorize (scope and select) objects. May match selectors of replication controllers and services. More info: http://kubernetes.io/docs/user-guide/labels"', args=[d.arg(name='labels', type=d.T.object)]),
    withLabels(labels): { metadata+: { labels: labels } },
    '#withLabelsMixin':: d.fn(help='"Map of string keys and values that can be used to organize and categorize (scope and select) objects. May match selectors of replication controllers and services. More info: http://kubernetes.io/docs/user-guide/labels"\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='labels', type=d.T.object)]),
    withLabelsMixin(labels): { metadata+: { labels+: labels } },
    '#withName':: d.fn(help='"Name must be unique within a namespace. Is required when creating resources, although some resources may allow a client to request the generation of an appropriate name automatically. Name is primarily intended for creation idempotence and configuration definition. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/identifiers#names"', args=[d.arg(name='name', type=d.T.string)]),
    withName(name): { metadata+: { name: name } },
    '#withNamespace':: d.fn(help='"Namespace defines the space within which each name must be unique. An empty namespace is equivalent to the \\"default\\" namespace, but \\"default\\" is the canonical representation. Not all objects are required to be scoped to a namespace - the value of this field for those objects will be empty.\\n\\nMust be a DNS_LABEL. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/namespaces"', args=[d.arg(name='namespace', type=d.T.string)]),
    withNamespace(namespace): { metadata+: { namespace: namespace } },
    '#withOwnerReferences':: d.fn(help='"List of objects depended by this object. If ALL objects in the list have been deleted, this object will be garbage collected. If this object is managed by a controller, then an entry in this list will point to this controller, with the controller field set to true. There cannot be more than one managing controller."', args=[d.arg(name='ownerReferences', type=d.T.array)]),
    withOwnerReferences(ownerReferences): { metadata+: { ownerReferences: if std.isArray(v=ownerReferences) then ownerReferences else [ownerReferences] } },
    '#withOwnerReferencesMixin':: d.fn(help='"List of objects depended by this object. If ALL objects in the list have been deleted, this object will be garbage collected. If this object is managed by a controller, then an entry in this list will point to this controller, with the controller field set to true. There cannot be more than one managing controller."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='ownerReferences', type=d.T.array)]),
    withOwnerReferencesMixin(ownerReferences): { metadata+: { ownerReferences+: if std.isArray(v=ownerReferences) then ownerReferences else [ownerReferences] } },
    '#withResourceVersion':: d.fn(help='"An opaque value that represents the internal version of this object that can be used by clients to determine when objects have changed. May be used for optimistic concurrency, change detection, and the watch operation on a resource or set of resources. Clients must treat these values as opaque and passed unmodified back to the server. They may only be valid for a particular resource or set of resources.\\n\\nPopulated by the system. Read-only. Value must be treated as opaque by clients and . More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#concurrency-control-and-consistency"', args=[d.arg(name='resourceVersion', type=d.T.string)]),
    withResourceVersion(resourceVersion): { metadata+: { resourceVersion: resourceVersion } },
    '#withSelfLink':: d.fn(help='"SelfLink is a URL representing this object. Populated by the system. Read-only.\\n\\nDEPRECATED Kubernetes will stop propagating this field in 1.20 release and the field is planned to be removed in 1.21 release."', args=[d.arg(name='selfLink', type=d.T.string)]),
    withSelfLink(selfLink): { metadata+: { selfLink: selfLink } },
    '#withUid':: d.fn(help='"UID is the unique in time and space value for this object. It is typically generated by the server on successful creation of a resource and is not allowed to change on PUT operations.\\n\\nPopulated by the system. Read-only. More info: http://kubernetes.io/docs/user-guide/identifiers#uids"', args=[d.arg(name='uid', type=d.T.string)]),
    withUid(uid): { metadata+: { uid: uid } },
  },
  '#new':: d.fn(help='new returns an instance of HelmChart', args=[d.arg(name='name', type=d.T.string)]),
  new(name): {
    apiVersion: 'source.toolkit.fluxcd.io/v1beta2',
    kind: 'HelmChart',
  } + self.metadata.withName(name=name),
  '#spec':: d.obj(help='"HelmChartSpec specifies the desired state of a Helm chart."'),
  spec: {
    '#accessFrom':: d.obj(help='"AccessFrom specifies an Access Control List for allowing cross-namespace\\nreferences to this object.\\nNOTE: Not implemented, provisional as of https://github.com/fluxcd/flux2/pull/2092"'),
    accessFrom: {
      '#namespaceSelectors':: d.obj(help='"NamespaceSelectors is the list of namespace selectors to which this ACL applies.\\nItems in this list are evaluated using a logical OR operation."'),
      namespaceSelectors: {
        '#withMatchLabels':: d.fn(help='"MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\\nmap is equivalent to an element of matchExpressions, whose key field is \\"key\\", the\\noperator is \\"In\\", and the values array contains only \\"value\\". The requirements are ANDed."', args=[d.arg(name='matchLabels', type=d.T.object)]),
        withMatchLabels(matchLabels): { matchLabels: matchLabels },
        '#withMatchLabelsMixin':: d.fn(help='"MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\\nmap is equivalent to an element of matchExpressions, whose key field is \\"key\\", the\\noperator is \\"In\\", and the values array contains only \\"value\\". The requirements are ANDed."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='matchLabels', type=d.T.object)]),
        withMatchLabelsMixin(matchLabels): { matchLabels+: matchLabels },
      },
      '#withNamespaceSelectors':: d.fn(help='"NamespaceSelectors is the list of namespace selectors to which this ACL applies.\\nItems in this list are evaluated using a logical OR operation."', args=[d.arg(name='namespaceSelectors', type=d.T.array)]),
      withNamespaceSelectors(namespaceSelectors): { spec+: { accessFrom+: { namespaceSelectors: if std.isArray(v=namespaceSelectors) then namespaceSelectors else [namespaceSelectors] } } },
      '#withNamespaceSelectorsMixin':: d.fn(help='"NamespaceSelectors is the list of namespace selectors to which this ACL applies.\\nItems in this list are evaluated using a logical OR operation."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='namespaceSelectors', type=d.T.array)]),
      withNamespaceSelectorsMixin(namespaceSelectors): { spec+: { accessFrom+: { namespaceSelectors+: if std.isArray(v=namespaceSelectors) then namespaceSelectors else [namespaceSelectors] } } },
    },
    '#sourceRef':: d.obj(help='"SourceRef is the reference to the Source the chart is available at."'),
    sourceRef: {
      '#withApiVersion':: d.fn(help='"APIVersion of the referent."', args=[d.arg(name='apiVersion', type=d.T.string)]),
      withApiVersion(apiVersion): { spec+: { sourceRef+: { apiVersion: apiVersion } } },
      '#withKind':: d.fn(help="\"Kind of the referent, valid values are ('HelmRepository', 'GitRepository',\\n'Bucket').\"", args=[d.arg(name='kind', type=d.T.string)]),
      withKind(kind): { spec+: { sourceRef+: { kind: kind } } },
      '#withName':: d.fn(help='"Name of the referent."', args=[d.arg(name='name', type=d.T.string)]),
      withName(name): { spec+: { sourceRef+: { name: name } } },
    },
    '#verify':: d.obj(help="\"Verify contains the secret name containing the trusted public keys\\nused to verify the signature and specifies which provider to use to check\\nwhether OCI image is authentic.\\nThis field is only supported when using HelmRepository source with spec.type 'oci'.\\nChart dependencies, which are not bundled in the umbrella chart artifact, are not verified.\""),
    verify: {
      '#matchOIDCIdentity':: d.obj(help="\"MatchOIDCIdentity specifies the identity matching criteria to use\\nwhile verifying an OCI artifact which was signed using Cosign keyless\\nsigning. The artifact's identity is deemed to be verified if any of the\\nspecified matchers match against the identity.\""),
      matchOIDCIdentity: {
        '#withIssuer':: d.fn(help='"Issuer specifies the regex pattern to match against to verify\\nthe OIDC issuer in the Fulcio certificate. The pattern must be a\\nvalid Go regular expression."', args=[d.arg(name='issuer', type=d.T.string)]),
        withIssuer(issuer): { issuer: issuer },
        '#withSubject':: d.fn(help='"Subject specifies the regex pattern to match against to verify\\nthe identity subject in the Fulcio certificate. The pattern must\\nbe a valid Go regular expression."', args=[d.arg(name='subject', type=d.T.string)]),
        withSubject(subject): { subject: subject },
      },
      '#secretRef':: d.obj(help='"SecretRef specifies the Kubernetes Secret containing the\\ntrusted public keys."'),
      secretRef: {
        '#withName':: d.fn(help='"Name of the referent."', args=[d.arg(name='name', type=d.T.string)]),
        withName(name): { spec+: { verify+: { secretRef+: { name: name } } } },
      },
      '#withMatchOIDCIdentity':: d.fn(help="\"MatchOIDCIdentity specifies the identity matching criteria to use\\nwhile verifying an OCI artifact which was signed using Cosign keyless\\nsigning. The artifact's identity is deemed to be verified if any of the\\nspecified matchers match against the identity.\"", args=[d.arg(name='matchOIDCIdentity', type=d.T.array)]),
      withMatchOIDCIdentity(matchOIDCIdentity): { spec+: { verify+: { matchOIDCIdentity: if std.isArray(v=matchOIDCIdentity) then matchOIDCIdentity else [matchOIDCIdentity] } } },
      '#withMatchOIDCIdentityMixin':: d.fn(help="\"MatchOIDCIdentity specifies the identity matching criteria to use\\nwhile verifying an OCI artifact which was signed using Cosign keyless\\nsigning. The artifact's identity is deemed to be verified if any of the\\nspecified matchers match against the identity.\"\n\n**Note:** This function appends passed data to existing values", args=[d.arg(name='matchOIDCIdentity', type=d.T.array)]),
      withMatchOIDCIdentityMixin(matchOIDCIdentity): { spec+: { verify+: { matchOIDCIdentity+: if std.isArray(v=matchOIDCIdentity) then matchOIDCIdentity else [matchOIDCIdentity] } } },
      '#withProvider':: d.fn(help='"Provider specifies the technology used to sign the OCI Artifact."', args=[d.arg(name='provider', type=d.T.string)]),
      withProvider(provider): { spec+: { verify+: { provider: provider } } },
    },
    '#withChart':: d.fn(help='"Chart is the name or path the Helm chart is available at in the\\nSourceRef."', args=[d.arg(name='chart', type=d.T.string)]),
    withChart(chart): { spec+: { chart: chart } },
    '#withIgnoreMissingValuesFiles':: d.fn(help='"IgnoreMissingValuesFiles controls whether to silently ignore missing values\\nfiles rather than failing."', args=[d.arg(name='ignoreMissingValuesFiles', type=d.T.boolean)]),
    withIgnoreMissingValuesFiles(ignoreMissingValuesFiles): { spec+: { ignoreMissingValuesFiles: ignoreMissingValuesFiles } },
    '#withInterval':: d.fn(help='"Interval at which the HelmChart SourceRef is checked for updates.\\nThis interval is approximate and may be subject to jitter to ensure\\nefficient use of resources."', args=[d.arg(name='interval', type=d.T.string)]),
    withInterval(interval): { spec+: { interval: interval } },
    '#withReconcileStrategy':: d.fn(help="\"ReconcileStrategy determines what enables the creation of a new artifact.\\nValid values are ('ChartVersion', 'Revision').\\nSee the documentation of the values for an explanation on their behavior.\\nDefaults to ChartVersion when omitted.\"", args=[d.arg(name='reconcileStrategy', type=d.T.string)]),
    withReconcileStrategy(reconcileStrategy): { spec+: { reconcileStrategy: reconcileStrategy } },
    '#withSuspend':: d.fn(help='"Suspend tells the controller to suspend the reconciliation of this\\nsource."', args=[d.arg(name='suspend', type=d.T.boolean)]),
    withSuspend(suspend): { spec+: { suspend: suspend } },
    '#withValuesFile':: d.fn(help='"ValuesFile is an alternative values file to use as the default chart\\nvalues, expected to be a relative path in the SourceRef. Deprecated in\\nfavor of ValuesFiles, for backwards compatibility the file specified here\\nis merged before the ValuesFiles items. Ignored when omitted."', args=[d.arg(name='valuesFile', type=d.T.string)]),
    withValuesFile(valuesFile): { spec+: { valuesFile: valuesFile } },
    '#withValuesFiles':: d.fn(help='"ValuesFiles is an alternative list of values files to use as the chart\\nvalues (values.yaml is not included by default), expected to be a\\nrelative path in the SourceRef.\\nValues files are merged in the order of this list with the last file\\noverriding the first. Ignored when omitted."', args=[d.arg(name='valuesFiles', type=d.T.array)]),
    withValuesFiles(valuesFiles): { spec+: { valuesFiles: if std.isArray(v=valuesFiles) then valuesFiles else [valuesFiles] } },
    '#withValuesFilesMixin':: d.fn(help='"ValuesFiles is an alternative list of values files to use as the chart\\nvalues (values.yaml is not included by default), expected to be a\\nrelative path in the SourceRef.\\nValues files are merged in the order of this list with the last file\\noverriding the first. Ignored when omitted."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='valuesFiles', type=d.T.array)]),
    withValuesFilesMixin(valuesFiles): { spec+: { valuesFiles+: if std.isArray(v=valuesFiles) then valuesFiles else [valuesFiles] } },
    '#withVersion':: d.fn(help='"Version is the chart version semver expression, ignored for charts from\\nGitRepository and Bucket sources. Defaults to latest when omitted."', args=[d.arg(name='version', type=d.T.string)]),
    withVersion(version): { spec+: { version: version } },
  },
  '#mixin': 'ignore',
  mixin: self,
}
