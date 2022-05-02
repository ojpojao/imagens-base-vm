source "qemu" "debian-11-gencloud-x86_64" {
  iso_url            = var.iso_url_8_x86_64
  iso_checksum       = var.iso_checksum_8_x86_64
  shutdown_command   = var.root_shutdown_command
  accelerator        = "kvm"
  http_directory     = var.http_directory
  ssh_username       = var.gencloud_ssh_username
  ssh_password       = var.gencloud_ssh_password
//  ssh_clear_authorized_keys = true
  ssh_timeout        = var.ssh_timeout
  cpus               = var.cpus
  disk_interface     = "virtio-scsi"
  disk_size          = var.gencloud_disk_size
  disk_cache         = "unsafe"
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  disk_compression   = true
  format             = "qcow2"
  headless           = var.headless
  memory             = var.memory
  net_device         = "virtio-net"
  qemu_binary        = var.qemu_binary
  vm_name            = "debian-11-GenericCloud-11.3-${formatdate("YYYYMMDD", timestamp())}.x86_64.qcow2"
  boot_wait          = var.boot_wait
  boot_command       = var.gencloud_boot_command_8_x86_64
}

build {
  sources = [
    "qemu.debian-11-gencloud-x86_64"
  ]

  provisioner "ansible" {
    playbook_file    = "./ansible/gencloud.yml"
    galaxy_file      = "./ansible/requirements.yml"
    roles_path       = "./ansible/roles"
    collections_path = "./ansible/collections"
    use_proxy = false
    ansible_env_vars = [
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS='-o ControlMaster=no -o ControlPersist=180s -o ServerAliveInterval=120s -o TCPKeepAlive=yes'"
      
    ]
    extra_arguments = [
      "-vvv",
      "-e", "ansible_ssh_private_key_file=./ansible/ssh/gencloud"
    ]
    ansible_ssh_extra_args = [ "IdentitiesOnly=no" ]
    ssh_host_key_file = "./ansible/ssh/gencloud.pub"
  }
}