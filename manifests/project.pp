define rundeck::project ($ensure = 'present',) {
  require('rundeck')

  if $ensure == 'present' {
    exec { "rundeck-project${name}":
      path    => '/usr/bin',
      command => "rd-project -p ${name} -a create",
      creates => "${rundeck::project_dir}/${name}",
    }
  } elsif $ensure == 'absent' {
    file { "${rundeck::project_dir}/${name}":
      ensure => absent,
      force  => true,
    }
  }
}
