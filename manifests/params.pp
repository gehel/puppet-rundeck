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
  $process_group = $::operatingsystem ? {
    default => 'rundeck',
  }
  $config_dir = $::operatingsystem ? {
    default => '/etc/rundeck',
  }
  $framework_file = $::operatingsystem ? {
    default => '/etc/rundeck/framework.properties',
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

  $resources_file = $::operatingsystem ? {
    default => '/var/rundeck/projects/resources.xml',
  }

  $template_dir = $::operatingsystem ? {
    default => '/var/rundeck/templates',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/rundeck',
  }

  $log_files = [
    "${log_dir}/rundeck.access.log",
    "${log_dir}/rundeck.api.log",
    "${log_dir}/rundeck.audit.log",
    "${log_dir}/rundeck.jobs.log",
    "${log_dir}/rundeck.log",
    "${log_dir}/rundeck.options.log",
    "${log_dir}/service.log",
    ]
  $log_file_mode = '0644'

  $username = 'admin'
  $password = 'admin'
  $server_name = 'localhost'
  $port = '4440'
  $protocol = 'tcp'
  $manage_repos = false

  $projects = {
  }

  # General Settings
  $my_class = ''
  $source = ''
  $framework_source = ''
  $source_dir = ''
  $source_dir_purge = false
  $ssh_private_key = ''
  $template = 'rundeck/rundeck-config.properties.erb'
  $project_template = 'rundeck/project/project.properties.erb'
  $framework_template = 'rundeck/framework.properties.erb'
  $version = 'present'
  $options = ''
  $service_autorestart = true
  $absent = false
  $disable = false
  $disableboot = false

  # Node settings
  $node_name = $::hostname
  $node_description = undef
  $node_hostname = $::fqdn
  $node_osArch = $::architecture
  $node_osFamily = $::osfamily
  $node_osName = $::operatingsystem
  $node_tags = []
  $node_editUrl = undef
  $node_remoteUrl = undef
  $node_attributes = []
  $node_template = 'rundeck/project/resources-node.xml.erb'
  $node_username = 'rundeck_node'
  $node_home_dir = '/var/lib/rundeck_node'
  $node_ssh_public_key = ''
  $node_ssh_public_key_type = 'ssh-rsa'
  $node_ssh_options = []

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