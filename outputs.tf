output "vdi_instance_public_ip" {
  description = "IP público da instância VDI."
  value       = oci_core_instance.vdi_instance.public_ip
}

output "vdi_instance_ocid" {
  description = "OCID da instância VDI."
  value       = oci_core_instance.vdi_instance.id
}

output "ssh_command" {
  description = "Comando para conectar via SSH à instância (substitua o caminho da chave se necessário)."
  value       = "ssh ubuntu@${oci_core_instance.vdi_instance.public_ip}" # Alterado de 'debian' para 'ubuntu'
}

output "vnc_connection_info" {
  description = "Para conectar via VNC, use o IP público e a porta 5901 (ex: SEU_IP_PUBLICO:5901). A senha foi definida na variável 'pass_instance'."
  value       = "${oci_core_instance.vdi_instance.public_ip}:5901"
}

output "found_images" {
  value = data.oci_core_images.ubuntu_image.images
}