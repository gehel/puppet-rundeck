class rundeck::server () {
  class { 'rundeck::repository': }

  package { 'rundeck':
    ensure  => $rundeck::manage_package,
    name    => $rundeck::package,
    require => Class['rundeck::repository'],
  }

  if $rundeck::bool_absent == false {
    service { 'rundeck':
      ensure    => $rundeck::manage_service_ensure,
      name      => $rundeck::service,
      enable    => $rundeck::manage_service_enable,
      hasstatus => $rundeck::service_status,
      pattern   => $rundeck::process,
      require   => Package['rundeck'],
    }
  }

  file { 'rundeck-ssh-dir':
    ensure  => $rundeck::manage_directory,
    path    => "${rundeck::data_dir}/.ssh",
    mode    => '0644',
    owner   => $rundeck::process_user,
    group   => $rundeck::config_file_group,
    require => Package['rundeck'],
    replace => $rundeck::manage_file_replace,
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-ssh-private-key':
    ensure  => $rundeck::manage_file,
    path    => "${rundeck::data_dir}/.ssh/id_rsa",
    mode    => '0600',
    owner   => $rundeck::process_user,
    group   => $rundeck::config_file_group,
    require => Package['rundeck'],
    content => $rundeck::ssh_private_key,
    replace => $rundeck::manage_file_replace,
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-config.properties':
    ensure  => $rundeck::manage_file,
    path    => $rundeck::config_file,
    mode    => $rundeck::config_file_mode,
    owner   => $rundeck::config_file_owner,
    group   => $rundeck::config_file_group,
    require => Package['rundeck'],
    notify  => $rundeck::manage_service_autorestart,
    source  => $rundeck::manage_file_source,
    content => $rundeck::manage_file_content,
    replace => $rundeck::manage_file_replace,
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-framework.properties':
    ensure  => $rundeck::manage_file,
    path    => $rundeck::framework_file,
    mode    => $rundeck::config_file_mode,
    owner   => $rundeck::config_file_owner,
    group   => $rundeck::config_file_group,
    require => Package['rundeck'],
    notify  => $rundeck::manage_service_autorestart,
    source  => $rundeck::manage_framework_file_source,
    content => $rundeck::manage_framework_file_content,
    replace => $rundeck::manage_file_replace,
    audit   => $rundeck::manage_audit,
  }

  concat::fragment { "rundeck-resource-node-header":
    target  => "${rundeck::project_dir}/resources.xml",
    content => '<project>',
    order   => 0,
    tag     => 'rundeck-resource-node',
  }

  Concat::Fragment <<| tag == 'rundeck-resource-node' |>>

  concat::fragment { "rundeck-resource-node-footer":
    target  => "${rundeck::project_dir}/resources.xml",
    content => '</project>',
    order   => 99,
    tag     => 'rundeck-resource-node',
  }

  concat { "${rundeck::project_dir}/resources.xml":
    ensure => $rundeck::manage_file,
    mode   => $rundeck::config_file_mode,
    owner  => $rundeck::config_file_owner,
    group  => $rundeck::config_file_group,
  }

  file { 'rundeck-template.dir':
    ensure  => $manage_directory,
    path    => $rundeck::template_dir,
    mode    => $rundeck::config_file_mode,
    owner   => $rundeck::config_file_owner,
    group   => $rundeck::config_file_group,
    purge   => true,
    require => Package['rundeck'],
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-template-jobs.dir':
    ensure  => $manage_directory,
    path    => $rundeck::template_job_dir,
    mode    => $rundeck::config_file_mode,
    owner   => $rundeck::config_file_owner,
    group   => $rundeck::config_file_group,
    purge   => true,
    require => Package['rundeck'],
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-log.dir':
    ensure  => $manage_directory,
    path    => $rundeck::log_dir,
    mode    => $rundeck::log_file_mode,
    owner   => $rundeck::process_user,
    group   => $rundeck::config_file_group,
    recurse => true,
    purge   => false,
    require => Package['rundeck'],
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-tmp-dir':
    ensure  => $rundeck::manage_directory,
    path    => "${rundeck::data_dir}/var/tmp",
    mode    => '0775',
    owner   => $rundeck::process_user,
    group   => $rundeck::process_group,
    require => Package['rundeck'],
    replace => $rundeck::manage_file_replace,
    audit   => $rundeck::manage_audit,
  }

  file { 'rundeck-pluginJars-dir':
    ensure  => $rundeck::manage_directory,
    path    => "${rundeck::data_dir}/var/tmp/pluginJars",
    mode    => '0775',
    owner   => $rundeck::process_user,
    group   => $rundeck::process_group,
    require => Package['rundeck'],
    replace => $rundeck::manage_file_replace,
    audit   => $rundeck::manage_audit,
  }

  # ## Provide puppi data, if enabled ( puppi => true )
  if $rundeck::bool_puppi == true {
    $classvars = get_class_args()

    puppi::ze { 'rundeck':
      ensure    => $rundeck::manage_file,
      variables => $classvars,
      helper    => $rundeck::puppi_helper,
    }

    puppi::log { 'rundeck':
      log         => $rundeck::log_files,
      description => 'Rundeck logs',
    }
  }

  # ## Service monitoring, if enabled ( monitor => true )
  if $rundeck::bool_monitor == true {
    monitor::port { "rundeck_${rundeck::protocol}_${rundeck::port}":
      protocol => $rundeck::protocol,
      port     => $rundeck::port,
      target   => $rundeck::monitor_target,
      tool     => $rundeck::monitor_tool,
      enable   => $rundeck::manage_monitor,
    }

    monitor::process { 'rundeck_process':
      process  => $rundeck::process,
      service  => $rundeck::service,
      pidfile  => $rundeck::pid_file,
      user     => $rundeck::process_user,
      argument => $rundeck::process_args,
      tool     => $rundeck::monitor_tool,
      enable   => $rundeck::manage_monitor,
    }
  }

  # ## Firewall management, if enabled ( firewall => true )
  if $rundeck::bool_firewall == true {
    firewall { "rundeck_${rundeck::protocol}_${rundeck::port}":
      source      => $rundeck::firewall_src,
      destination => $rundeck::firewall_dst,
      protocol    => $rundeck::protocol,
      port        => $rundeck::port,
      action      => 'allow',
      direction   => 'input',
      tool        => $rundeck::firewall_tool,
      enable      => $rundeck::manage_firewall,
    }
  }

  create_resources('rundeck::project', $projects)
}