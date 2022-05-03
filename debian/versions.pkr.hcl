packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/qemu"
    }
    proxmox = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}