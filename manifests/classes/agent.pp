# Class:vormetric_mauri::agent
#
# This module manages TrendMicro DeepSecurity Agent 9.0
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#   (See test/init.pp)
class vormetric_mauri::agent(
) inherits vormetric_mauri::params {

  # perform this only when node tagging is completed
  #if $appcara::params::server {

    case $::operatingsystem {
        # Linux-based computers
        'debian','ubuntu','redhat','centos','Amazon': {
            class { 'vormetric_mauri::agent::linux::install': }
            class { 'vormetric_mauri::agent::linux::config': }
            Class['vormetric_mauri::agent::linux::install']
              -> Class['vormetric_mauri::agent::linux::config']
        }
		'windows': {
            class { 'vormetric_mauri::agent::windows::install': }
            class { 'vormetric_mauri::agent::windows::config': }
            Class['vormetric_mauri::agent::windows::install']
              -> Class['vormetric_mauri::agent::windows::config']
	    }
        # Other OS
        default: {
            notice("Unsupported OS: $::operatingsystem")
        }
    } # end case
    
  #} # end if $appcara::params::server

} # end of class
