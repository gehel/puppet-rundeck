class rundeck::node (
  $node_name   = hiera('rundeck_node_name', $::hostname),
  $description = hiera('rundeck_node_description', undef),
  $hostname    = hiera('rundeck_node_hostname', $::fqdn),
  $osArch      = hiera('rundeck_node_osArch', $::architecture),
  $osFamily    = hiera('rundeck_node_osFamily', $::osfamily),
  $osName      = hiera('rundeck_node_osName', $::operatingsystem),
  $tags        = hiera('rundeck_node_tags', []),
  $username    = hiera('rundeck_node_username', 'rundeck'),
  $editUrl     = hiera('rundeck_node_editUrl', undef),
  $remoteUrl   = hiera('rundeck_node_remoteUrl', undef),
  $attributes  = hiera('rundeck_node_attributes', []),
  $template    = hiera('rundeck_node_template', 'rundeck/project/resources-node.xml.erb')) {
  validate_array($tags)
  validate_array($attributes)

  @@concat::fragment { "rundeck-resource-node-${::fqdn}":
    target  => '/var/rundeck/projects/resources.xml',
    content => template($template),
    order   => 10,
    tag     => 'rundeck-resource-node',
  }

}