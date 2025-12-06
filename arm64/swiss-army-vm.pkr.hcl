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
  default = "0dd2f82a5dd53cb9c6abd92d30070d23bcbfd7dfb55309be4ac07245df3999b9"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/archive/12.12.0/arm64/iso-cd/debian-12.12.0-arm64-netinst.iso"
}

variable "memsize" {
  type    = string
  default = "2048"
}

variable "numvcpus" {
  type    = string
  default = "2"
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
  # Boot configuration for ARM64 UEFI/GRUB
  boot_wait = "${var.boot_wait}"
  boot_command = [
    "<wait10>c<wait3>",
    "linux /install.a64/vmlinuz auto=true url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg priority=critical debian-installer/language=en debian-installer/country=US debian-installer/locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=us netcfg/choose_interface=auto ---<enter><wait2>",
    "initrd /install.a64/initrd.gz<enter><wait2>",
    "boot<enter>"
  ]

  # Disk configuration
  disk_size          = "${var.disk_size}"
  disk_type_id       = "0"
  disk_adapter_type  = "nvme"
  
  # CD-ROM configuration
  cdrom_adapter_type = "sata"
  
  # Network configuration
  network_adapter_type = "e1000e"
  
  # Guest OS type
  guest_os_type = "arm-debian12-64"
  
  # Display
  headless = false
  
  # HTTP server for preseed
  http_directory = "../http/arm64"
  
  # ISO configuration
  iso_checksum = "${var.iso_checksum}"
  iso_url      = "${var.iso_url}"
  
  # Shutdown
  shutdown_command = "echo 'packer'|sudo -S shutdown -P now"
  
  # SSH configuration
  ssh_password = "${var.ssh_password}"
  ssh_port     = 22
  ssh_timeout  = "60m"
  ssh_username = "${var.ssh_username}"
  ssh_wait_timeout = "60m"
  
  # VM name
  vm_name = "${var.vm_name}"
  
  # VMX data
  vmx_data = {
    architecture               = "arm64"
    memsize                    = "${var.memsize}"
    numvcpus                   = "${var.numvcpus}"
    "ethernet0.virtualdev"     = "e1000e"
    "ethernet0.present"        = "TRUE"
    "ethernet0.connectiontype" = "nat"
    "usb_xhci.present"         = "true"
    "virtualHW.version"        = "20"
  }
  
  # VNC for debugging
  vnc_disable_password = true
}

build {
  sources = ["source.vmware-iso.swiss-army-vmware"]

  provisioner "shell" {
   execute_command = "sudo -E /bin/bash '{{ .Path }}'"

    scripts = [
      "../scripts/arm64/system-initial-configuration-arm64.sh",
      "../scripts/arm64/network-monitoring-and-analysis-tooling-arm64.sh",
      "../scripts/arm64/vulnerability-assessment-tooling-arm64.sh",
      "../scripts/arm64/endpoint-analysis-tooling-arm64.sh",
      "../scripts/arm64/prune-packages-arm64.sh",
      "../scripts/arm64/system-hardening.sh",
      "../scripts/arm64/setup-tool-updates.sh"
    ]

    
  }
}
