class rundeck::node {
  @@concat::fragment { "rundeck-resource-node-${::fqdn}":
    target  => '/var/rundeck/projects/resources.xml',
    content => template($rundeck::node_template),
    order   => 10,
    tag     => 'rundeck-resource-node',
  }

  user { 'rundeck_node_user':
    name       => $rundeck::node_username,
    shell      => '/bin/sh',
    home       => $rundeck::node_home_dir,
    managehome => true,
  } -> ssh_authorized_key { 'Rundeck agent':
    user    => $rundeck::node_username,
    key     => $rundeck::node_ssh_public_key,
    type    => $rundeck::node_ssh_public_key_type,
    options => $rundeck::node_ssh_options
  }
}
