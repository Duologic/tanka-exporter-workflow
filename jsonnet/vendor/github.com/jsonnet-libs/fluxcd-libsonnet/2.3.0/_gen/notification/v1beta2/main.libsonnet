{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='v1beta2', url='', help=''),
  alert: (import 'alert.libsonnet'),
  provider: (import 'provider.libsonnet'),
  receiver: (import 'receiver.libsonnet'),
}
