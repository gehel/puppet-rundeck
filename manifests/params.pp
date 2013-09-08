class rundeck::params {
  $package = $::operatingsystem ? {
    default => 'rundeck',
  }

  $service = $::operatingsystem ? {
    default => 'rundeckd',
  }
  $service_status = $::operatingsystem ? {
    default => true,
  }
  $process = $::operatingsystem ? {
    default => 'java',
  }
  $process_args = $::operatingsystem ? {
    default => 'rundeck',
  }
  $process_user = $::operatingsystem ? {
    default => 'rundeck',
  }
  $config_dir = $::operatingsystem ? {
    default => '/etc/rundeck',
  }
  $config_file = $::operatingsystem ? {
    default => '/etc/rundeck/rundeck-config.properties',
  }
  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'rundeck',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'rundeck',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/rundeck.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/rundeck',
  }

  $project_dir = $::operatingsystem ? {
    default => '/var/rundeck/projects',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/rundeck',
  }

  $port = '4440'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $version = 'present'
  $options = ''
  $service_autorestart = true
  $absent = false
  $disable = false
  $disableboot = false

  # ## General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = '127.0.0.1'
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false
}