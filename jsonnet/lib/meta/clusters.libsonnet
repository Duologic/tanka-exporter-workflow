// synthesize cluster metadata, this should come from provisioning resources
{
  [std.join('-', [status, region, number])]: {
    name: std.join('-', [status, region, number]),
    status: status,
    region: region,
    apiServer: 'https://127.0.%s.1:8443' % number,
  }
  for status in ['dev', 'stag', 'prod']
  for region in ['us-central', 'eu-west']
  for number in std.map(function(n) std.toString(n), std.range(0, 1))
}
