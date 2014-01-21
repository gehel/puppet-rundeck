define rundeck::project (
  $ensure              = 'present',
  $jobs                = {
  }
  ,
  $template            = $rundeck::project_template,
  $ssh_authentication  = 'privateKey',
  $ssh_keypath         = "${rundeck::data_dir}/.ssh/id_rsa",
  $service_node_executor_default_provider        = 'jsch-ssh',
  $service_file_copier_default_provider          = 'jsch-scp',
  $resources_include_server_node = false,
  $resources_generate_file_automatically = false,
  $resources_file      = $rundeck::resources_file,) {
  validate_bool($resources_include_server_node)
  validate_bool($resources_generate_file_automatically)

  include rundeck

  case $ensure {
    'present' : {
      file { "rundeck-project-resources-${name}":
        path    => "${rundeck::project_dir}/${name}/etc/resources.xml",
        ensure  => 'link',
        target  => "${rundeck::project_dir}/resources.xml",
        mode    => $rundeck::config_file_mode,
        owner   => $rundeck::config_file_owner,
        group   => $rundeck::config_file_group,
        replace => $rundeck::manage_file_replace,
        audit   => $rundeck::manage_audit,
        require => Package[$rundeck::package],
      }

      exec { "rundeck-project-${name}":
        path    => '/usr/bin',
        command => "rd-project -p ${name} -a create",
        user    => $rundeck::process_user,
        creates => "${rundeck::project_dir}/${name}",
        require => Package[$rundeck::package],
      } -> file { "rundeck-project-properties":
        path    => "${rundeck::project_dir}/${name}/etc/project.properties",
        ensure  => $ensure,
        content => template($template),
        mode    => $rundeck::config_file_mode,
        owner   => $rundeck::config_file_owner,
        group   => $rundeck::config_file_group,
        replace => $rundeck::manage_file_replace,
        audit   => $rundeck::manage_audit,
        require => Package[$rundeck::package],
      }
    }
    'absent'  : {
      file { "rundeck-project-resources-${name}":
        path   => "${rundeck::project_dir}/${name}/etc/resources.xml",
        ensure => $ensure,
      }

      file { "${rundeck::project_dir}/${name}":
        ensure => $ensure,
        force  => true,
      }
    }
    default   : {
      fail("rundeck::project only supports 'present' and 'absent', '${ensure}' is unknown.'")
    }
  }

  create_resources('rundeck::job', $jobs, {
    'project' => $name
  }
  )
}
