class rundeck::node (
  $node_name           = hiera('rundeck_node_name', $::hostname),
  $description         = hiera('rundeck_node_description', undef),
  $hostname            = hiera('rundeck_node_hostname', $::fqdn),
  $osArch              = hiera('rundeck_node_osArch', $::architecture),
  $osFamily            = hiera('rundeck_node_osFamily', $::osfamily),
  $osName              = hiera('rundeck_node_osName', $::operatingsystem),
  $tags                = hiera('rundeck_node_tags', []),
  $editUrl             = hiera('rundeck_node_editUrl', undef),
  $remoteUrl           = hiera('rundeck_node_remoteUrl', undef),
  $attributes          = hiera('rundeck_node_attributes', []),
  $template            = hiera('rundeck_node_template', 'rundeck/project/resources-node.xml.erb'),
  $username            = hiera('rundeck_node_username', 'rundeck_node'),
  $home_dir            = hiera('rundeck_node_home_dir', '/var/lib/rundeck_node'),
  $ssh_public_key      = hiera('rundeck_ssh_public_key', ''),
  $ssh_public_key_type = hiera('rundeck_ssh_public_key_type', 'ssh-rsa')) {
  validate_array($tags)
  validate_array($attributes)

  @@concat::fragment { "rundeck-resource-node-${::fqdn}":
    target  => '/var/rundeck/projects/resources.xml',
    content => template($template),
    order   => 10,
    tag     => 'rundeck-resource-node',
  }

  user { 'rundeck_node_user':
    name  => $username,
    home  => $home_dir,
    shell => '/bin/sh',
  } -> file { 'rundeck_node_home':
    path => $home_dir,
    ensure => 'directory',
    owner  => $username,
    mode   => '0755',
  } -> ssh_authorized_key { 'Rundeck agent':
    user => $username,
    key  => $ssh_public_key,
    type => $ssh_public_key_type,
  }

}
