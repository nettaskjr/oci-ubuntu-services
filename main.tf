terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid # Availability domains are global to the tenancy
  ad_number      = 1                # Escolha o AD número 1, 2 ou 3.
}

# Obtém a imagem mais recente do Ubuntu LTS para a forma da instância (Não funcionou, testar novamente)
# data "oci_core_images" "ubuntu_image" {
#   compartment_id          = var.tenancy_ocid #= var.compartment_ocid # Pode ser necessário ajustar para o OCID do compartimento de imagens da Oracle, se diferente.
#   operating_system        = "Ubuntu"             # Alterado para Ubuntu
#   operating_system_version = "22.04"            # Especificando Ubuntu 22.04 LTS. Verifique as versões disponíveis no console OCI.
#   sort_by                 = "TIMECREATED"
#   sort_order              = "DESC"
#   shape                   = var.instance_shape # Filtra imagens compatíveis com a forma
# }

# Se a busca acima não funcionar bem ou para ser mais específico,
# você pode precisar encontrar o OCID da imagem manualmente no Console da OCI
# e atribuí-lo diretamente ou através de uma variável.
# Exemplo de OCID de imagem (substitua por um OCID válido para sua região e forma):
# variable "ubuntu_image_ocid" {
#   description = "OCID específico da imagem Ubuntu com GUI ou base para GUI."
#   default     = "ocid1.image.oc1.iad.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # EXEMPLO
# }

resource "oci_core_vcn" "vdi_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "VdiVcn"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "vdivcn"
}

resource "oci_core_internet_gateway" "vdi_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vdi_vcn.id
  display_name   = "VdiInternetGateway"
}

resource "oci_core_default_route_table" "vcn_default_route_table" {
  manage_default_resource_id = oci_core_vcn.vdi_vcn.default_route_table_id
  display_name               = "VdiDefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.vdi_igw.id
  }
}

resource "oci_core_subnet" "vdi_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vdi_vcn.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "VdiSubnet"
  dns_label                  = "vdisubnet"
  prohibit_public_ip_on_vnic = false # Permite IP público para acesso
  route_table_id             = oci_core_vcn.vdi_vcn.default_route_table_id
  security_list_ids          = [oci_core_vcn.vdi_vcn.default_security_list_id] # Usaremos um NSG dedicado
}

resource "oci_core_network_security_group" "vdi_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vdi_vcn.id
  display_name   = "VdiNsg"
}

resource "oci_core_network_security_group_security_rule" "allow_ssh" {
  network_security_group_id = oci_core_network_security_group.vdi_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "Permitir acesso SSH de qualquer lugar"
}

resource "oci_core_network_security_group_security_rule" "allow_vnc" {
  network_security_group_id = oci_core_network_security_group.vdi_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  tcp_options {
    destination_port_range {
      min = 5901 # Porta padrão do VNC para display :1
      max = 5901
    }
  }
  description = "Permitir acesso VNC de qualquer lugar (Display :1)"
}

# Se você preferir RDP ao invés de VNC:
# resource "oci_core_network_security_group_security_rule" "allow_rdp" {
#   network_security_group_id = oci_core_network_security_group.vdi_nsg.id
#   direction                 = "INGRESS"
#   protocol                  = "6" # TCP
#   source                    = "0.0.0.0/0"
#   source_type               = "CIDR_BLOCK"
#   stateless                 = false
#   tcp_options {
#     destination_port_range {
#       min = 3389
#       max = 3389
#     }
#   }
#   description = "Permitir acesso RDP de qualquer lugar"
# }

resource "oci_core_instance" "vdi_instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  dynamic "shape_config" {
    for_each = substr(var.instance_shape, 0, 2) == "VM" && split(".", var.instance_shape)[1] == "Standard" && split(".", var.instance_shape)[2] == "A1" ? [1] : []
    content {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_in_gbs
    }
  }

  dynamic "shape_config" {
    for_each = substr(var.instance_shape, 0, 2) == "VM" && split(".", var.instance_shape)[1] == "Standard" && (split(".", var.instance_shape)[2] == "E2" || split(".", var.instance_shape)[2] == "E3" || split(".", var.instance_shape)[2] == "E4") ? [1] : []
    content {
      ocpus         = var.instance_ocpus # Para E2.1.Micro, OCPUs e Memória são fixos, mas o provider pode esperar.
      memory_in_gbs = var.instance_memory_in_gbs
    }
  }

  source_details {
    source_type = "image"
    # source_id   = data.oci_core_images.ubuntu_image.images[0].id # Alterado para usar a imagem Ubuntu (não funcionou)
    source_id               = var.ubuntu_image_ocid # Use esta linha se você especificou um OCID de imagem manualmente
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vdi_subnet.id
    assign_public_ip = true # Necessário para acesso externo
    nsg_ids          = [oci_core_network_security_group.vdi_nsg.id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # user_data           = base64encode(file("${path.module}/cloud_init.yaml")) # LINHA ANTIGA
    user_data = base64encode(templatefile("${path.module}/cloud_init.yaml", { # LINHA NOVA
      user_instance = var.user_instance
      pass_instance = var.pass_instance
    }))
  }

  preserve_boot_volume = false # Defina como true se quiser manter o volume de inicialização após a exclusão da instância

  timeouts {
    create = "60m"
  }
}