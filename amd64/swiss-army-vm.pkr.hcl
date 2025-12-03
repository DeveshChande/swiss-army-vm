packer {
  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
  }
}

variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "disk_size" {
  type    = string
  default = "40960"
}

variable "iso_checksum" {
  type    = string
  default = "dfc30e04fd095ac2c07e998f145e94bb8f7d3a8eca3a631d2eb012398deae531"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso"
}

variable "memsize" {
  type    = string
  default = "4096"
}

variable "numvcpus" {
  type    = string
  default = "1"
}

variable "ssh_password" {
  type    = string
  default = "packer"
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "vm_name" {
  type    = string
  default = "Swiss-Army-VM"
}

source "vmware-iso" "swiss-army-vmware" {
  boot_command     = ["<esc>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]
  boot_wait        = "${var.boot_wait}"
  disk_size        = "${var.disk_size}"
  disk_type_id     = "0"
  guest_os_type    = "debian10-64"
  headless         = false
  http_directory   = "../http/amd64/"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  shutdown_command = "echo 'packer'|sudo -S shutdown -P now"
  ssh_password     = "${var.ssh_password}"
  ssh_port         = 22
  ssh_timeout      = "30m"
  ssh_username     = "${var.ssh_username}"
  vm_name          = "${var.vm_name}"
  vmx_data = {
    memsize             = "${var.memsize}"
    numvcpus            = "${var.numvcpus}"
    "virtualHW.version" = "14"
  }
}

build {
  sources = ["source.vmware-iso.swiss-army-vmware"]

  provisioner "shell" {
    scripts = [
      "../scripts/amd64/system-initial-configuration-amd64.sh",
      "../scripts/amd64/network-monitoring-and-analysis-tooling-amd64.sh",
      "../scripts/amd64/vulnerability-assessment-tooling-amd64.sh",
      "../scripts/amd64/endpoint-analysis-tooling-amd64.sh",
      "../scripts/amd64/file-analysis-tooling-amd64.sh",
      "../scripts/amd64/prune-packages-amd64.sh",
      "../scripts/amd64/system-hardening.sh",
      "../scripts/amd64/setup-tool-updates.sh"
    ]

    execute_command = "sudo -E /bin/bash '{{ .Path }}'"
  }


}
