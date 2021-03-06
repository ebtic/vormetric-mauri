class vormetric_mauri::agent::windows::install (
) {

  #install python
  case $architecture {
    i386, i686: {
	  package { "pythontestM":
        ensure   => installed,
        provider => 'msi', 
        source   => 'http://www.python.org/ftp/python/2.7.5/python-2.7.5.msi',
        install_options => [{'ALLUSERS' => '1'}],
      }		
	}
    x64, x86_64, amd64: { 
	  package { "pythontestM":
        ensure   => installed,
        provider => 'msi', 
        source   => 'http://www.python.org/ftp/python/2.7.5/python-2.7.5.amd64.msi',
	    install_options => [{'ALLUSERS' => '1'}],
      }    		
	}
	default: {
	  file { "C:/$architecture":
	    ensure => directory, 
        mode   => '0777',
        owner  => 'Administrator',
        group  => 'Administrators',
      }
	}  
  }

  #create management folder
  $vm_management_folder = "C:/btconfigtestM"
  # -amazon- $agent_download_url = "ec2-54-161-187-162.compute-1.amazonaws.com"
  $agent_download_url = "10.255.92.70"
  $vm_dns = "$::appstack_server_identifier.$::domain"
	
  if $vormetric_mauri::params::files_existed == "true" {
	
	file { "$vm_management_folder":
	  ensure => directory, 
      mode   => '0777',
      owner  => 'Administrator',
      group  => 'Administrators',
    }	
  
    #download python code
    file { "$vm_management_folder/vormetric_agent_management.py":
	  ensure  => file,
      mode    => '0777',
      owner   => 'Administrator',
      group   => 'Administrators',      
      source  => "puppet:///modules/vormetric_mauri/vormetric_agent_management.py",
      require => File["$vm_management_folder"],
    }
	  	  
	case $vormetric_mauri::params::vm_state{      
	  'subscribed':{
	    exec { "vormetric_agent_subscription":
	      cwd     => "$vm_management_folder",
          path    => "C:/Python27",
		  creates => "C:/ProgramData/PuppetLabs/facter/facts.d/vormetric_facts.txt",
	      command => "python vormetric_agent_management.py subscribe $vm_dns",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
	    }
	  }
	
	  'registered':{
	    exec { "vormetric_agent_installation":
		  cwd     => "$vm_management_folder",
          path    => "C:/Python27",
		  creates => "C:/Program Files/Vormetric/DataSecurityExpert/agent/vmd/bin/vmd.exe",
	      command => "python vormetric_agent_management.py install $agent_download_url $vormetric_mauri::params::host_ip $vormetric_mauri::params::host_dns $vm_dns",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
	    }
		  
	    exec { "vormetric_agent_configuration":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  creates => "C:/ProgramData/Vormetric/DataSecurityExpert/agent/vmd/pem/agent.pem",
		  command => "python vormetric_agent_management.py register $vormetric_mauri::params::host_dns $vm_dns",
		  require => [Exec["vormetric_agent_installation"]],
        }
      }	
		
	  'Encryption':{
		exec { "vormetric_data_encryption":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  command => "python vormetric_agent_management.py encrypt $vormetric_mauri::params::guardpoint",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
		}
	  }
		
	  'Decryption':{
		exec { "vormetric_data_decryption":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  command => "python vormetric_agent_management.py decrypt update $vormetric_mauri::params::guardpoint",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
		}
	  }
	  
	  'Clear':{
	    exec { "vormetric_data_clear":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  command => "python vormetric_agent_management.py decrypt update $vormetric_mauri::params::guardpoint",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
		}
	  }
	  
	  'Uninstallation':{
	    exec { "vormetric_data_uninstallation":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  command => "python vormetric_agent_management.py uninstall",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
		}
	  }
	  
	  'Unsubscription':{
	    exec { "vormetric_data_decryption_special":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  command => "python vormetric_agent_management.py decrypt noupdate $vormetric_mauri::params::guardpoint",
          require => [Package["pythontestM"], [File["${vm_management_folder}/vormetric_agent_management.py"]]],
		}
		
		exec { "vormetric_data_uninstallation":
		  cwd     => "$vm_management_folder",
		  path    => "C:/Python27",
		  command => "python vormetric_agent_management.py uninstall",
          require => [Exec["vormetric_data_decryption_special"]],
		}
	  }
    }
  }	
  else{
    #TODO for service un-subscription 
	#remove python code
    file { "${vm_management_folder}/vormetric_agent_management.py":
      ensure  => absent,
    }
  }
}
