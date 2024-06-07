VM_NAME = debian12

PHONY: init build

init:
	packer init ${VM_NAME}.pkr.hcl
	export PACKER_LOG=1

build:
	packer build -force ${VM_NAME}.pkr.hcl

help:
	@echo "Uso:"
	@echo "  make help           Exibe esta mensagem de ajuda"
	@echo "  make init           Prepara o ambiente para a execução do Packer"
	@echo "  make build          Constrói a imagem base com o Packer"