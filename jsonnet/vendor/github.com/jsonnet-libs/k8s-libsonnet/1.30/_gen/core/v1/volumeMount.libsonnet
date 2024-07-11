{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='volumeMount', url='', help='"VolumeMount describes a mounting of a Volume within a container."'),
  '#withMountPath':: d.fn(help="\"Path within the container at which the volume should be mounted.  Must not contain ':'.\"", args=[d.arg(name='mountPath', type=d.T.string)]),
  withMountPath(mountPath): { mountPath: mountPath },
  '#withMountPropagation':: d.fn(help='"mountPropagation determines how mounts are propagated from the host to container and the other way around. When not set, MountPropagationNone is used. This field is beta in 1.10. When RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified (which defaults to None)."', args=[d.arg(name='mountPropagation', type=d.T.string)]),
  withMountPropagation(mountPropagation): { mountPropagation: mountPropagation },
  '#withName':: d.fn(help='"This must match the Name of a Volume."', args=[d.arg(name='name', type=d.T.string)]),
  withName(name): { name: name },
  '#withReadOnly':: d.fn(help='"Mounted read-only if true, read-write otherwise (false or unspecified). Defaults to false."', args=[d.arg(name='readOnly', type=d.T.boolean)]),
  withReadOnly(readOnly): { readOnly: readOnly },
  '#withRecursiveReadOnly':: d.fn(help='"RecursiveReadOnly specifies whether read-only mounts should be handled recursively.\\n\\nIf ReadOnly is false, this field has no meaning and must be unspecified.\\n\\nIf ReadOnly is true, and this field is set to Disabled, the mount is not made recursively read-only.  If this field is set to IfPossible, the mount is made recursively read-only, if it is supported by the container runtime.  If this field is set to Enabled, the mount is made recursively read-only if it is supported by the container runtime, otherwise the pod will not be started and an error will be generated to indicate the reason.\\n\\nIf this field is set to IfPossible or Enabled, MountPropagation must be set to None (or be unspecified, which defaults to None).\\n\\nIf this field is not specified, it is treated as an equivalent of Disabled."', args=[d.arg(name='recursiveReadOnly', type=d.T.string)]),
  withRecursiveReadOnly(recursiveReadOnly): { recursiveReadOnly: recursiveReadOnly },
  '#withSubPath':: d.fn(help="\"Path within the volume from which the container's volume should be mounted. Defaults to \\\"\\\" (volume's root).\"", args=[d.arg(name='subPath', type=d.T.string)]),
  withSubPath(subPath): { subPath: subPath },
  '#withSubPathExpr':: d.fn(help="\"Expanded path within the volume from which the container's volume should be mounted. Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment. Defaults to \\\"\\\" (volume's root). SubPathExpr and SubPath are mutually exclusive.\"", args=[d.arg(name='subPathExpr', type=d.T.string)]),
  withSubPathExpr(subPathExpr): { subPathExpr: subPathExpr },
  '#mixin': 'ignore',
  mixin: self,
}