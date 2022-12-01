terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

####sno1#####
# resource "libvirt_network" "snolab1-net" {
#   # the name used by libvirt
#   name = "snolab1-net"

#   # mode can be: "nat" (default), "none", "route", "open", "bridge"
#   mode = "open"

#   #  the domain used by the DNS server in this network
#   domain = "ocpd1.snolab1.local"

#   addresses = ["10.17.5.0/24", "2001:db8:ca2:3::1/64"]

#   dns {
#     enabled = true
#     local_only = false

#     # (Optional) one or more DNS forwarder entries.  One or both of
#     # "address" and "domain" must be specified.  The format is:
#     forwarders {
#         address = "10.17.4.1"
#         domain = "ocpd.snolab.local"
#      } 
#     # 

#     # (Optional) one or more DNS host entries.  Both of
#     # "ip" and "hostname" must be specified.  The format is:
#     hosts  {
#         hostname = "ocp4-sno1.ocpd1.snolab1.local"
#         ip = "10.17.5.2"
#       }
#   }

#   # (Optional) Dnsmasq options configuration
#   dnsmasq_options {
#     options {
#         option_name = "host-record"
#         option_value = "api.ocpd1.snolab1.local,10.17.5.2"
#       }    
#     options {
#         option_name = "host-record"
#         option_value = "api-int.ocpd1.snolab1.local,10.17.5.2"
#       }    
#     options {
#         option_name = "address"
#         option_value = "/.apps.ocpd1.snolab1.local/10.17.5.2"
#       }    
#     options {
#         option_name = "dhcp-host"
#         option_value = "ba:bb:cc:12:82:20,ocp4-sno1.ocpd1.snolab1.local,10.17.5.2"
#       }    
#   }
# }

resource "libvirt_volume" "fatdisk-sno1" {
  name           = "fatdisk-sno1"
  pool           = "images"
  size           = 130000000000
}


resource "libvirt_domain" "sno1" {
  name   = "ocp4-sno1"
  memory = "96000"
  arch="x86_64" 
  machine="q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  vcpu   = 8
  cpu  {
  mode = "host-passthrough"
  }
  running = false
  boot_device {
      dev = ["hd","cdrom"]
    }
  network_interface {
    network_name = "snolab1-net"
    mac = "ba:bb:cc:12:82:20"
  }
  network_interface {
    network_name = "snolab-net"
    mac = "be:bb:cc:12:82:20"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id =  "${libvirt_volume.fatdisk-sno1.id}"
    scsi      = "true"
  }
  disk {
      file = "/var/lib/libvirt/images/dummy.iso"
    }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
  # depends_on = [
  #   libvirt_network.snolab1-net
  # ]
}
output "sno1_UUID" {
  value = "${libvirt_domain.sno1.id}"
}