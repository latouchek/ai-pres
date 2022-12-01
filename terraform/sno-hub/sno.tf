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


resource "libvirt_volume" "fatdisk-sno" {
  name           = "fatdisk-sno"
  pool           = "images"
  size           = 130000000000
}

resource "libvirt_volume" "volume-mon-sno" {
  name   = "volume-mon-sno"
  pool   = "images"
  size   = "30000000000"
  format = "qcow2"
}
resource "libvirt_volume" "volume-osd1-sno" {
  name   = "volume-osd1-sno"
  pool   = "images"
  size   = "30000000000"
  format = "qcow2"
}
resource "libvirt_volume" "volume-osd2-sno" {
  name   = "volume-osd2-sno"
  pool   = "images"
  size   = "30000000000"
  format = "qcow2"
}

resource "libvirt_domain" "sno" {
  name   = "ocp4-sno"
  memory = "96000"
  vcpu   = 8
  cpu  {
  mode = "host-passthrough"
  }
  running = true
  boot_device {
      dev = ["hd","cdrom"]
    }
  network_interface {
    network_name = "snolab-net"
    mac = "ba:bb:cc:11:82:20"
  }
  network_interface {
    network_name = "snolab1-net"
    mac = "ba:ba:cc:11:82:20"
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
    volume_id =  "${libvirt_volume.fatdisk-sno.id}"
  }
  disk {
      file = "/var/lib/libvirt/images/discovery_image.iso"
    }
  disk {
    volume_id = "${libvirt_volume.volume-mon-sno.id}"
  }
  disk {
    volume_id = "${libvirt_volume.volume-osd1-sno.id}"
  }
  disk {
    volume_id = "${libvirt_volume.volume-osd2-sno.id}"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
