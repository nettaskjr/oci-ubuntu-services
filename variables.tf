variable "tenancy_ocid" {
  description = "OCID da sua tenancy. Pode ser encontrado no console da OCI em Administração > Detalhes da Tenancy."
  type        = string
  # sensitive   = true
}

variable "user_ocid" {
  description = "OCID do seu usuário. Pode ser encontrado no console da OCI em Identidade > Usuários."
  type        = string
  # sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint da sua chave API. Pode ser encontrado no console da OCI em Identidade > Usuários > Chaves API."
  type        = string
  # sensitive   = true
}

variable "private_key_path" {
  description = "Caminho para a sua chave privada API no formato PEM."
  type        = string
  # sensitive   = true
}

variable "region" {
  description = "Região da OCI onde os recursos serão criados. Ex: us-ashburn-1"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCID do compartimento onde os recursos serão criados."
  type        = string
}

variable "instance_shape" {
  description = "Forma da instância. Para Free Tier, considere VM.Standard.E2.1.Micro ou VM.Standard.A1.Flex (com OCPUs e memória limitados)."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_ocpus" {
  description = "Número de OCPUs para a instância (relevante para formas Flex como VM.Standard.A1.Flex)."
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Quantidade de memória em GBs para a instância (relevante para formas Flex)."
  type        = number
  default     = 1
}

variable "boot_volume_size_in_gbs" {
  description = "Tamanho do volume de inicialização em GBs."
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "Conteúdo da sua chave pública SSH para acesso à instância."
  type        = string
  # sensitive   = true
}

variable "vnc_password" {
  description = "Senha para o acesso VNC. Deve ter entre 6 e 8 caracteres."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.vnc_password) >= 6 && length(var.vnc_password) <= 8
    error_message = "A senha VNC deve ter entre 6 e 8 caracteres."
  }
}

variable "instance_display_name" {
  description = "Nome de exibição para a instância VDI."
  type        = string
  default     = "ubuntu-gnome-vdi" # Alterado para refletir Ubuntu
}

variable "vdi_user" {
  description = "Nome do usuário para a sessão VDI."
  type        = string
  default     = "vduser"
}