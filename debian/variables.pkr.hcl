variables {
  //
  // common variables
  //
  iso_url_8_x86_64       = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.3.0-amd64-netinst.iso"
  iso_checksum_8_x86_64  = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS"
  headless               = false
  boot_wait              = "10s"
  cpus                   = 2
  memory                 = 2048
  post_cpus              = 1
  post_memory            = 1024
  http_directory         = "http"
  ssh_timeout            = "3600s"
  root_shutdown_command  = "/sbin/shutdown -hP now"
  qemu_binary            = ""
  firmware_x86_64        = "/usr/share/OVMF/OVMF_CODE.fd"


  gencloud_boot_command_8_x86_64 = [
    "<tab>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><wait>",
//    " net.ifnames=0",
//    " biosdevname=0",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
    " -- <wait>",
    "<enter><wait>"

  ]
  gencloud_disk_size         = "3G"
  gencloud_ssh_username      = "root"
  gencloud_ssh_password      = "debian"
  gencloud_boot_wait_ppc64le = "8s"
}

