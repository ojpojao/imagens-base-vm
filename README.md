# Criando imagens base de VMs

Templates para criação de imagens-base para máquinas virtuais com o QEMU e Hashicorp Packer.
O Ansible será o _provisioner_ do Packer - ele executa ações desejadas dentro da VM de build.

_**IPC.:**_ a pasta _```ansible```_ é uma adaptação do repositório de cloud-images do [Alma Linux](https://github.com/AlmaLinux/cloud-images/).

## Sistemas suportados
No momento, estes são os sistemas suportados pelos templates:
- Debian [12.4.0](https://cdimage.debian.org/mirror/cdimage/archive/12.4.0/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso)

## Requisitos
- packer (>= 1.7.0)
- qemu
- ansible
- fedora 40 -> validado somente aqui

## Instalando pré-requisitos
###
```bash
# instala os pacotes
sudo dnf install \
    ansible \
    make \
    qemu \
    git \
    unzip
```

### Packer
```bash
PACKER_VERSION="1.11.0"
cd /tmp
curl -fsSL https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -o packer.zip
unzip packer.zip
sudo mv packer /usr/local/bin/packer
sudo chmod +x /usr/local/bin/packer
unset PACKER_VERSION
```

## Build da imagem
```bash
git clone https://github.com/ojpojao/imagens-base-vm.git
cd images-base-vm
```

O template está configurado para executar em modo _headless_ - sem interface gráfica. Para habilitá-la, edite o template no argumento ```_headless = true_``` e mude para _```false```_ antes de rodar o comando de _build_.

O build pode ser executado através dos comandos que estão no _Makefile_. Para verificar os comandos disponíveis, digite ```make help```.

Ajuda:
```bash
➜  make help
Uso:
  make help           Exibe esta mensagem de ajuda
  make init           Prepara o ambiente para a execução do Packer
  make build          Constrói a imagem base com o Packer
```

Build:
```bash
make init
make build
```
```bash
# output do Packer
packer build -force debian12.pkr.hcl
qemu.debian12: output will be in this color.

==> qemu.debian12: Retrieving ISO
==> qemu.debian12: Trying https://cdimage.debian.org/mirror/cdimage/archive/12.4.0/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso
==> qemu.debian12: Trying https://cdimage.debian.org/mirror/cdimage/archive/12.4.0/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso?checksum=sha256%3A64d727dd5785ae5fcfd3ae8ffbede5f40cca96f1580aaa2820e8b99dae989d94
==> qemu.debian12: https://cdimage.debian.org/mirror/cdimage/archive/12.4.0/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso?checksum=sha256%3A64d727dd5785ae5fcfd3ae8ffbede5f40cca96f1580aaa2820e8b99dae989d94 => /home/ojpojao/.cache/packer/5db75c3c6f567036ff5
ede632b329e89a0fabd44.iso
==> qemu.debian12: Starting HTTP server on port 8570
==> qemu.debian12: Found port for communicator (SSH, WinRM, etc): 3154.
.
.
.
. restante da saída verbosa omitida
```

## Testando a imagem com o cloud-init
A imagem, será configurada com o cloud-init. Os arquivos de exemplo estão na pasta _```cloud-init```_. Referência de configuração do cloud-init [aqui](https://cloudinit.readthedocs.io/en/latest/index.html).

#### Cria o disco _```cloud-init```_ dentro da pasta _```output```_
```bash
# cloud-init iso
genisoimage \
    -output output/cloud-init.iso \
    -volid cidata -rational-rock -joliet \
    cloud-init/user-data cloud-init/meta-data cloud-init/network-config
```

#### Rodando a VM
```bash
cp output/debian*.qcow2 output/instance.qcow2
qemu-img resize output/instance.qcow2 +10G

qemu-system-x86_64 \
    -name debian12 \
    -machine type=q35,accel=kvm \
    -cpu host \
    -m 2048M \
    -boot once=dc \
    -device e1000,netdev=eth0 \
    -netdev user,id=eth0,hostfwd=tcp::22222-:22 \
    -drive file=output/cloud-init.iso,if=ide,media=cdrom \
    -drive file=output/instance.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2 \
    -vnc 0.0.0.0:40 \
    -nographic
```

#### Logando na VM
```bash
# usuario: debian; senha: passwd - como configurado nos arquivos do cloud-init
SeaBIOS (version 1.16.3-2.fc40)


iPXE (https://ipxe.org) 00:02.0 CA00 PCI2.10 PnP PMM+7EFC9C00+7EF09C00 CA00



Booting from Hard Disk...
GRUB loading.
Welcome to GRUB!


Debian GNU/Linux 12 debian ttyS0

debian login:
```
```bash
debian login: debian
Password:
Linux debian 6.1.0-21-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.90-1 (2024-05-03) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Thu Jun 13 04:32:57 -03 2024 on ttyS0
debian@debian:~$
```

Referências:
- @ansible [https://www.ansible.com/](https://www.ansible.com/)
- @cloud-init [https://cloud-init.io/](https://cloud-init.io/)
- @AlmaLinux [AlmaLinux cloud-images](https://github.com/AlmaLinux/cloud-images/)
- @hashicorp [Packer - https://developer.hashicorp.com/packer](https://developer.hashicorp.com/packer)
- @qemu [https://www.qemu.org/](https://www.qemu.org/)
- @debian [https://www.debian.org](https://www.debian.org/)