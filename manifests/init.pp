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
  $my_class                 = params_lookup('my_class'),
  $source                   = params_lookup('source'),
  $framework_source         = params_lookup('framework_source'),
  $source_dir               = params_lookup('source_dir'),
  $source_dir_purge         = params_lookup('source_dir_purge'),
  $template                 = params_lookup('template'),
  $project_template         = params_lookup('project_template'),
  $framework_template       = params_lookup('framework_template'),
  $service_autorestart      = params_lookup('service_autorestart', 'global'),
  $options                  = params_lookup('options'),
  $version                  = params_lookup('version'),
  $absent                   = params_lookup('absent'),
  $disable                  = params_lookup('disable'),
  $disableboot              = params_lookup('disableboot'),
  $monitor                  = params_lookup('monitor', 'global'),
  $monitor_tool             = params_lookup('monitor_tool', 'global'),
  $monitor_target           = params_lookup('monitor_target', 'global'),
  $puppi                    = params_lookup('puppi', 'global'),
  $puppi_helper             = params_lookup('puppi_helper', 'global'),
  $firewall                 = params_lookup('firewall', 'global'),
  $firewall_tool            = params_lookup('firewall_tool', 'global'),
  $firewall_src             = params_lookup('firewall_src', 'global'),
  $firewall_dst             = params_lookup('firewall_dst', 'global'),
  $debug                    = params_lookup('debug', 'global'),
  $audit_only               = params_lookup('audit_only', 'global'),
  $package                  = params_lookup('package'),
  $service                  = params_lookup('service'),
  $service_status           = params_lookup('service_status'),
  $process                  = params_lookup('process'),
  $process_args             = params_lookup('process_args'),
  $process_user             = params_lookup('process_user'),
  $process_group            = params_lookup('process_group'),
  $ssh_private_key          = params_lookup('ssh_private_key'),
  $config_dir               = params_lookup('config_dir'),
  $config_file              = params_lookup('config_file'),
  $framework_file           = params_lookup('framework_file'),
  $config_file_mode         = params_lookup('config_file_mode'),
  $config_file_owner        = params_lookup('config_file_owner'),
  $config_file_group        = params_lookup('config_file_group'),
  $pid_file                 = params_lookup('pid_file'),
  $data_dir                 = params_lookup('data_dir'),
  $project_dir              = params_lookup('project_dir'),
  $resources_file           = params_lookup('resources_file'),
  $template_dir             = params_lookup('template_dir'),
  $server_name              = params_lookup('server_name'),
  $log_dir                  = params_lookup('log_dir'),
  $log_files                = params_lookup('log_files'),
  $log_file_mode            = params_lookup('log_file_mode'),
  $username                 = params_lookup('username'),
  $password                 = params_lookup('password'),
  $manage_repos             = params_lookup('manage_repos'),
  $port                     = params_lookup('port'),
  $protocol                 = params_lookup('protocol'),
  $projects                 = params_lookup('projects'),
  $mode                     = params_lookup('mode'),
  $node_name                = params_lookup('node_name'),
  $node_description         = params_lookup('node_description'),
  $node_hostname            = params_lookup('node_hostname'),
  $node_osArch              = params_lookup('node_osArch'),
  $node_osFamily            = params_lookup('node_osFamily'),
  $node_osName              = params_lookup('node_osName'),
  $node_tags                = params_lookup('node_tags'),
  $node_editUrl             = params_lookup('node_editUrl'),
  $node_remoteUrl           = params_lookup('node_remoteUrl'),
  $node_attributes          = params_lookup('node_attributes'),
  $node_template            = params_lookup('node_template'),
  $node_username            = params_lookup('node_username'),
  $node_home_dir            = params_lookup('node_home_dir'),
  $node_ssh_public_key      = params_lookup('node_ssh_public_key'),
  $node_ssh_public_key_type = params_lookup('node_ssh_public_key_type'),
  $node_ssh_options         = params_lookup('node_ssh_options')) inherits rundeck::params {
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
  $array_mode = any2array($mode)

  validate_array($node_tags)
  validate_array($node_attributes)
  validate_array($node_ssh_options)

  # ## Definition of some variables used in the module
  $manage_package = $rundeck::bool_absent ? {
    true    => 'absent',
    default => $rundeck::version,
  }

  $manage_service_enable = $rundeck::bool_disableboot ? {
    true    => false,
    default => $rundeck::bool_disable ? {
      true    => false,
      default => true,
    },
  }

  $manage_service_ensure = $rundeck::bool_disable ? {
    true    => 'stopped',
    default => 'running',
  }

  $manage_service_autorestart = $rundeck::bool_service_autorestart ? {
    false   => undef,
    default => $rundeck::bool_absent ? {
      true    => undef,
      default => 'Service[rundeck]',
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
    true    => 'all',
    default => undef,
  }

  $manage_file_replace = $rundeck::bool_audit_only ? {
    true    => false,
    default => true,
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

  if 'server' in $array_mode {
    include rundeck::server
  }

  if 'node' in $array_mode {
    include rundeck::node
  }

  # ## Managed resources

  # ## Include custom class if $my_class is set
  if $rundeck::my_class {
    include $rundeck::my_class
  }

}
