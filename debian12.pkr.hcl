packer {
    required_version = ">= 1.7.0"
    required_plugins {
        qemu = {
            version = ">= 1.0.9"
            source = "github.com/hashicorp/qemu"
        }

        ansible = {
            version = ">= 1.1.0"
            source = "github.com/hashicorp/ansible"
        }
    }
}

source "qemu" "debian12" {

    iso_url = "https://cdimage.debian.org/mirror/cdimage/archive/12.4.0/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso"
    iso_checksum = "file:https://cdimage.debian.org/mirror/cdimage/archive/12.4.0/amd64/iso-cd/SHA256SUMS"

    # Sobe um servidor HTTP para baixar o arquivo de preseed.cfg desta pasta
    http_directory = "http"
    output_directory = "output"
    vm_name = "debian-12.4.0-${formatdate("YYYYMMDD", timestamp())}.x86_64.qcow2"

    ssh_username = "root"
    ssh_password = "debian"
    ssh_timeout = "60m"

    headless = true # roda a VM de build sem interface gráfica
    cpus = 2
    accelerator = "kvm"
    disk_size = "10G"
    format = "qcow2"
    disk_interface = "virtio"
    disk_compression = true
    memory = 2048
    net_device = "virtio-net"

    boot_wait = "10s"
    boot_command = [
        "<tab>",
        "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><wait1s>",
        " auto-install/enable=true",
        " debconf/priority=critical",
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait1s>",
        " ---<wait1s>",
        "<enter><wait1s>"
    ]

    shutdown_command = "shutdown -hP now"
}

build {
    sources = [
        "source.qemu.debian12"
    ]

    provisioner "ansible" {
        playbook_file = "./ansible/gencloud.yml"
        galaxy_file = "./ansible/requirements.yml"
        roles_path = "./ansible/roles"
        collections_path = "./ansible/collections"

        use_proxy = false
        ansible_env_vars = [
            "ANSIBLE_PIPELINING=True",
            "ANSIBLE_HOST_KEY_CHECKING=False",
            "ANSIBLE_REMOTE_TEMP=/tmp/ansible"
        ]

        # Não remover "inventory_file_template". Sem o inventário declarado com o "ansible_password" deu erro no build.
        # Exemplo do inventário que dá erro: "default ansible_host=127.0.0.1 ansible_user=root ansible_port=4440"
        inventory_file_template = "default ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_password={{ .Password }}\n"
        keep_inventory_file = false # opcional. use para debug do "inventory_file_template"

        ## descomentar quando quiser mais verbosidade do Ansible
        # extra_arguments = [ "-vvv" ]
    }
}
