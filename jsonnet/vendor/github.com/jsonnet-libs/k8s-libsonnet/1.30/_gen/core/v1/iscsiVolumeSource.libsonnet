{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='iscsiVolumeSource', url='', help='"Represents an ISCSI disk. ISCSI volumes can only be mounted as read/write once. ISCSI volumes support ownership management and SELinux relabeling."'),
  '#secretRef':: d.obj(help='"LocalObjectReference contains enough information to let you locate the referenced object inside the same namespace."'),
  secretRef: {
    '#withName':: d.fn(help='"Name of the referent. This field is effectively required, but due to backwards compatibility is allowed to be empty. Instances of this type with an empty value here are almost certainly wrong. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names"', args=[d.arg(name='name', type=d.T.string)]),
    withName(name): { secretRef+: { name: name } },
  },
  '#withChapAuthDiscovery':: d.fn(help='"chapAuthDiscovery defines whether support iSCSI Discovery CHAP authentication"', args=[d.arg(name='chapAuthDiscovery', type=d.T.boolean)]),
  withChapAuthDiscovery(chapAuthDiscovery): { chapAuthDiscovery: chapAuthDiscovery },
  '#withChapAuthSession':: d.fn(help='"chapAuthSession defines whether support iSCSI Session CHAP authentication"', args=[d.arg(name='chapAuthSession', type=d.T.boolean)]),
  withChapAuthSession(chapAuthSession): { chapAuthSession: chapAuthSession },
  '#withFsType':: d.fn(help='"fsType is the filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: \\"ext4\\", \\"xfs\\", \\"ntfs\\". Implicitly inferred to be \\"ext4\\" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi"', args=[d.arg(name='fsType', type=d.T.string)]),
  withFsType(fsType): { fsType: fsType },
  '#withInitiatorName':: d.fn(help='"initiatorName is the custom iSCSI Initiator Name. If initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface <target portal>:<volume name> will be created for the connection."', args=[d.arg(name='initiatorName', type=d.T.string)]),
  withInitiatorName(initiatorName): { initiatorName: initiatorName },
  '#withIqn':: d.fn(help='"iqn is the target iSCSI Qualified Name."', args=[d.arg(name='iqn', type=d.T.string)]),
  withIqn(iqn): { iqn: iqn },
  '#withIscsiInterface':: d.fn(help="\"iscsiInterface is the interface Name that uses an iSCSI transport. Defaults to 'default' (tcp).\"", args=[d.arg(name='iscsiInterface', type=d.T.string)]),
  withIscsiInterface(iscsiInterface): { iscsiInterface: iscsiInterface },
  '#withLun':: d.fn(help='"lun represents iSCSI Target Lun number."', args=[d.arg(name='lun', type=d.T.integer)]),
  withLun(lun): { lun: lun },
  '#withPortals':: d.fn(help='"portals is the iSCSI Target Portal List. The portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260)."', args=[d.arg(name='portals', type=d.T.array)]),
  withPortals(portals): { portals: if std.isArray(v=portals) then portals else [portals] },
  '#withPortalsMixin':: d.fn(help='"portals is the iSCSI Target Portal List. The portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260)."\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='portals', type=d.T.array)]),
  withPortalsMixin(portals): { portals+: if std.isArray(v=portals) then portals else [portals] },
  '#withReadOnly':: d.fn(help='"readOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false."', args=[d.arg(name='readOnly', type=d.T.boolean)]),
  withReadOnly(readOnly): { readOnly: readOnly },
  '#withTargetPortal':: d.fn(help='"targetPortal is iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260)."', args=[d.arg(name='targetPortal', type=d.T.string)]),
  withTargetPortal(targetPortal): { targetPortal: targetPortal },
  '#mixin': 'ignore',
  mixin: self,
}
