class rundeck::repository {
  if $rundeck::manage_repos {
    case $::operatingsystem {
      /(?i:Ubuntu|Mint|Debian)/ : {
        apt::repository { 'rundeck':
          url        => 'http://dl.bintray.com/rundeck/candidate-deb',
          distro     => '',
          repository => '/',
        }
      }
      default: {
        notice("Unknown operating system $::operatingsystem")
      }
    }
  }
}