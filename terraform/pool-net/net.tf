resource "libvirt_network" "lab-net" {
  # the name used by libvirt
  name = "lab-net"

  # mode can be: "nat" (default), "none", "route", "open", "bridge"
  mode = "nat"

  #  the domain used by the DNS server in this network
  domain = "ocpd.lab.local"

  addresses = ["10.17.3.0/24", "2001:db8:ca2:2::1/64"]

  dns {
    enabled = true
    local_only = false
    hosts  {
        hostname = "ocp4-sno0.ocpd.lab.local"
        ip = "10.17.3.20"
      }
  }

  dnsmasq_options {
    options {
        option_name = "host-record"
        option_value = "api.ocpd.lab.local,10.17.3.2"
      }    
    options {
        option_name = "host-record"
        option_value = "ocp4-master0.ocpd.lab.local,10.17.3.10"
      }    
    options {
        option_name = "host-record"
        option_value = "ocp4-master1.ocpd.lab.local,10.17.3.11"
      }    
    options {
        option_name = "host-record"
        option_value = "ocp4-master2.ocpd.lab.local,10.17.3.12"
      }          
    options {
        option_name = "host-record"
        option_value = "ocp4-worker0.ocpd.lab.local,10.17.3.13"
      }                
    options {
        option_name = "host-record"
        option_value = "ocp4-worker1.ocpd.lab.local,10.17.3.14"
      }                
    options {
        option_name = "host-record"
        option_value = "ocp4-worker2.ocpd.lab.local,10.17.3.15"
      }                
    options {
        option_name = "address"
        option_value = "/.apps.ocpd.lab.local/10.17.3.3"
      }    
    options {
        option_name = "dhcp-host"
        option_value = "aa:bb:cc:11:82:20,ocp4-sno0.ocpd.lab.local,10.17.3.10"
      }
     options {
        option_name = "server"
        option_value = "/ocpd1.snolab1.local/10.17.5.1"
      }    
        
  }
}
resource "libvirt_network" "snolab1-net" {
  # the name used by libvirt
  name = "snolab1-net"
  mode = "none"
  domain = "ocpd1.snolab1.local"

  addresses = ["10.17.5.0/24", "2001:db8:ca2:3::1/64"]

  dns {
    enabled = true
    local_only = false
    hosts  {
        hostname = "ocp4-sno1.ocpd1.snolab1.local"
        ip = "10.17.5.3"
      }
  }
  dnsmasq_options {
    options {
        option_name = "host-record"
        option_value = "api.ocpd1.snolab1.local,10.17.5.3"
      }    
    options {
        option_name = "host-record"
        option_value = "api-int.ocpd1.snolab1.local,10.17.5.3"
      }    
    options {
        option_name = "address"
        option_value = "/.apps.ocpd1.snolab1.local/10.17.5.3"
      }    
    options {
        option_name = "dhcp-host"
        option_value = "ba:bb:cc:12:82:20,ocp4-sno1.ocpd1.snolab1.local,10.17.5.3"
      }    
    options {
        option_name = "server"
        option_value = "/ocpd.snolab.local/10.17.4.1"
      }    
  }
}
resource "libvirt_network" "snolab-net" {
  # the name used by libvirt
  name = "snolab-net"
  mode = "nat"
  domain = "snolab.local"
  addresses = ["10.17.4.0/24", "2001:db8:ca2:2::1/64"]
  dns {
    enabled = true
    local_only = false
    hosts  {
        hostname = "ocp4-sno0.ocpd.snolab.local"
        ip = "10.17.4.2"
      }
  }
  dnsmasq_options {
    options {
        option_name = "host-record"
        option_value = "api.ocpd.snolab.local,10.17.4.2"
      }    
    options {
        option_name = "host-record"
        option_value = "api-int.ocpd.snolab.local,10.17.4.2"
      }    
   options {
        option_name = "host-record"
        option_value = "ocp4-sno0.ocpd.snolab.local,10.17.4.2"
      }    
    options {
        option_name = "host-record"
        option_value = "ocp4-sno1.ocpd.snolab.local,10.17.4.3"
      }    
    options {
        option_name = "host-record"
        option_value = "ocp4-sno2.ocpd.snolab.local,10.17.4.4"
      }          
    options {
        option_name = "host-record"
        option_value = "ocp4-worker0.ocpd.snolab.local,10.17.4.13"
      }                
    options {
        option_name = "host-record"
        option_value = "ocp4-worker1.ocpd.snolab.local,10.17.4.14"
      }                
    options {
        option_name = "host-record"
        option_value = "ocp4-worker2.ocpd.snolab.local,10.17.4.15"
      }                
    options {
        option_name = "address"
        option_value = "/.apps.snolab.local/10.17.4.2"
      }    
    options {
        option_name = "dhcp-host"
        option_value = "ba:bb:cc:11:82:20,ocp4-sno0.snolab.local,10.17.4.2"
      } 
    options {
        option_name = "server"
        option_value = "/ocpd1.snolab1.local/10.17.5.1"
      }    
   }     
  }

