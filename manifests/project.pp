define rundeck::project (
  $ensure   = 'present',
  $jobs     = {
  }
  ,
  $template = 'rundeck/project/resources.xml.erb',) {
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
        content => template(),
        replace => $rundeck::manage_file_replace,
        audit   => $rundeck::manage_audit,
      }

      exec { "rundeck-project-${name}":
        path    => '/usr/bin',
        command => "rd-project -p ${name} -a create",
        creates => "${rundeck::project_dir}/${name}",
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
