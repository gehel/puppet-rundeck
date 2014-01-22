# Class: rundeck
#
# This module manages rundeck
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class rundeck (
  $my_class            = params_lookup('my_class'),
  $source              = params_lookup('source'),
  $framework_source    = params_lookup('framework_source'),
  $source_dir          = params_lookup('source_dir'),
  $source_dir_purge    = params_lookup('source_dir_purge'),
  $template            = params_lookup('template'),
  $project_template    = params_lookup('project_template'),
  $framework_template  = params_lookup('framework_template'),
  $service_autorestart = params_lookup('service_autorestart', 'global'),
  $options             = params_lookup('options'),
  $version             = params_lookup('version'),
  $absent              = params_lookup('absent'),
  $disable             = params_lookup('disable'),
  $disableboot         = params_lookup('disableboot'),
  $monitor             = params_lookup('monitor', 'global'),
  $monitor_tool        = params_lookup('monitor_tool', 'global'),
  $monitor_target      = params_lookup('monitor_target', 'global'),
  $puppi               = params_lookup('puppi', 'global'),
  $puppi_helper        = params_lookup('puppi_helper', 'global'),
  $firewall            = params_lookup('firewall', 'global'),
  $firewall_tool       = params_lookup('firewall_tool', 'global'),
  $firewall_src        = params_lookup('firewall_src', 'global'),
  $firewall_dst        = params_lookup('firewall_dst', 'global'),
  $debug               = params_lookup('debug', 'global'),
  $audit_only          = params_lookup('audit_only', 'global'),
  $package             = params_lookup('package'),
  $service             = params_lookup('service'),
  $service_status      = params_lookup('service_status'),
  $process             = params_lookup('process'),
  $process_args        = params_lookup('process_args'),
  $process_user        = params_lookup('process_user'),
  $process_group       = params_lookup('process_group'),
  $ssh_private_key     = params_lookup('ssh_private_key'),
  $config_dir          = params_lookup('config_dir'),
  $config_file         = params_lookup('config_file'),
  $framework_file      = params_lookup('framework_file'),
  $config_file_mode    = params_lookup('config_file_mode'),
  $config_file_owner   = params_lookup('config_file_owner'),
  $config_file_group   = params_lookup('config_file_group'),
  $pid_file            = params_lookup('pid_file'),
  $data_dir            = params_lookup('data_dir'),
  $project_dir         = params_lookup('project_dir'),
  $resources_file      = params_lookup('resources_file'),
  $template_dir        = params_lookup('template_dir'),
  $server_name         = params_lookup('server_name'),
  $log_dir             = params_lookup('log_dir'),
  $log_files           = params_lookup('log_files'),
  $log_file_mode       = params_lookup('log_file_mode'),
  $username            = params_lookup('username'),
  $password            = params_lookup('password'),
  $manage_repos        = params_lookup('manage_repos'),
  $port                = params_lookup('port'),
  $protocol            = params_lookup('protocol'),
  $projects            = params_lookup('projects')) inherits rundeck::params {
  $bool_source_dir_purge = any2bool($source_dir_purge)
  $bool_service_autorestart = any2bool($service_autorestart)
  $bool_absent = any2bool($absent)
  $bool_disable = any2bool($disable)
  $bool_disableboot = any2bool($disableboot)
  $bool_monitor = any2bool($monitor)
  $bool_puppi = any2bool($puppi)
  $bool_firewall = any2bool($firewall)
  $bool_debug = any2bool($debug)
  $bool_audit_only = any2bool($audit_only)
  $bool_manage_repos = any2bool($manage_repos)

  # ## Definition of some variables used in the module
  $manage_package = $rundeck::bool_absent ? {
    true  => 'absent',
    false => $rundeck::version,
  }

  $manage_service_enable = $rundeck::bool_disableboot ? {
    true    => false,
    default => $rundeck::bool_disable ? {
      true  => false,
      false => true,
    },
  }

  $manage_service_ensure = $rundeck::bool_disable ? {
    true  => 'stopped',
    false => 'running',
  }

  $manage_service_autorestart = $rundeck::bool_service_autorestart ? {
    false => undef,
    true  => $rundeck::bool_absent ? {
      true  => undef,
      false => 'Service[rundeck]',
    },
  }

  $manage_file = $rundeck::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_user = $rundeck::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_directory = $rundeck::bool_absent ? {
    true    => 'absent',
    default => 'directory',
  }

  if $rundeck::bool_absent == true or $rundeck::bool_disable == true or $rundeck::bool_disableboot == true {
    $manage_monitor = false
  } else {
    $manage_monitor = true
  }

  if $rundeck::bool_absent == true or $rundeck::bool_disable == true {
    $manage_firewall = false
  } else {
    $manage_firewall = true
  }

  $manage_audit = $rundeck::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $rundeck::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $rundeck::source ? {
    ''      => undef,
    default => $rundeck::source,
  }

  $manage_framework_file_source = $rundeck::framework_source ? {
    ''      => undef,
    default => $rundeck::framework_source,
  }

  $manage_file_content = $rundeck::template ? {
    ''      => undef,
    default => template($rundeck::template),
  }

  $manage_framework_file_content = $rundeck::framework_template ? {
    ''      => undef,
    default => template($rundeck::framework_template),
  }

  validate_hash($projects)
  $template_job_dir = "${rundeck::params::template_dir}/jobs"

  # ## Managed resources
  class { 'rundeck::repository':
  }

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

  # ## Include custom class if $my_class is set
  if $rundeck::my_class {
    include $rundeck::my_class
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
