# Servidor VDI ubuntu com GNOME na Oracle Cloud Infrastructure (OCI) - Free Tier

Este projeto Terraform provisiona uma máquina virtual (VM) na Oracle Cloud Infrastructure (OCI) configurada como um servidor de Virtual Desktop Infrastructure (VDI) utilizando ubuntu com a interface gráfica GNOME. O acesso ao desktop é feito via VNC.

## 🎯 Objetivo

O objetivo é fornecer uma configuração básica e automatizada para um ambiente de desktop remoto na nuvem, utilizando os recursos da Camada Gratuita (Free Tier) da OCI sempre que possível.

## ⚠️ Aviso sobre o Free Tier

Os recursos da Camada Gratuita da OCI estão sujeitos à disponibilidade e aos termos de serviço da Oracle. Este código tenta utilizar formas de VM e armazenamento elegíveis para o Free Tier, mas não há garantia de que estarão sempre disponíveis ou que não haverá custos se os limites forem excedidos. **Monitore seu uso no console da OCI.**

## 🛠️ Pré-requisitos

1.  **Conta OCI:** Você precisa de uma conta Oracle Cloud Infrastructure.
2.  **Terraform:** Instale o Terraform (versão 1.0.0 ou superior).
3.  **Credenciais OCI:**
    * OCID da Tenancy
    * OCID do Usuário
    * Fingerprint da Chave API
    * Caminho para a Chave Privada API (formato PEM)
    * OCID do Compartimento onde os recursos serão criados
    * Sua chave SSH pública

## ⚙️ Configuração

1.  **Clone o Repositório:**
    ```bash
    git clone git@github.com:nettaskjr/oci-vdi-ubuntu-gnome-vnc.git
    cd oci-vdi-ubuntu-gnome-vnc
    ```

2.  **Configure as Variáveis:**
    Crie um arquivo chamado `terraform.tfvars` na raiz do projeto e preencha com suas credenciais e configurações da OCI. Use o arquivo `variables.tf` como referência para as variáveis necessárias.

    Exemplo de `terraform.tfvars`:
    ```terraform
    tenancy_ocid      = "ocid1.tenancy.oc1..xxxxxxxxxxxx"
    user_ocid         = "ocid1.user.oc1..xxxxxxxxxxxx"
    fingerprint       = "xx:xx:xx:xx:xx:xx:xx:xx"
    private_key_path  = "~/.oci/oci_api_key.pem" # Ajuste o caminho
    region            = "us-ashburn-1"           # Sua região OCI
    compartment_ocid  = "ocid1.compartment.oc1..xxxxxxxxxxx"
    ssh_public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCl... user@host"
    vnc_password      = "SuaSenhaVNCSecreta" # Use uma senha entre 6-8 caracteres
    # Opcional: defina outras variáveis de 'variables.tf' se quiser mudar os defaults
    # instance_shape = "VM.Standard.A1.Flex"
    # instance_ocpus = 2
    # instance_memory_in_gbs = 4
    ```
    **Nota de Segurança:** O arquivo `terraform.tfvars` contém informações sensíveis e é ignorado pelo `.gitignore`. Não o envie para o repositório público.

## 🚀 Implantação

1.  **Inicialize o Terraform:**
    Navegue até o diretório do projeto e execute:
    ```bash
    terraform init
    ```

2.  **Planeje a Implantação:**
    (Opcional, mas recomendado) Verifique quais recursos serão criados:
    ```bash
    terraform plan
    ```

3.  **Aplique a Configuração:**
    Provisione os recursos na OCI:
    ```bash
    terraform apply
    ```
    Confirme digitando `yes` quando solicitado.

    Após a conclusão, o Terraform exibirá os outputs, incluindo o IP público da instância VDI.

## 🖥️ Acessando o VDI

1.  **Acesso SSH (Opcional, para gerenciamento):**
    Você pode acessar a instância via SSH usando o usuário padrão do ubuntu (`ubuntu`) e sua chave SSH:
    ```bash
    ssh ubuntu@<IP_PUBLICO_DA_INSTANCIA>
    ```
    O IP público é fornecido no output `vdi_instance_public_ip`.

2.  **Acesso VNC:**
    * **Cliente VNC:** Você precisará de um cliente VNC (como TigerVNC Viewer, RealVNC Viewer, TightVNC Viewer, etc.) instalado na sua máquina local.
    * **Endereço do Servidor:** Use o IP público da instância seguido da porta `5901` (que corresponde ao display `:1` configurado). Exemplo: `192.0.2.100:5901`.
    * **Senha:** Use a senha VNC que você definiu na variável `vnc_password` no arquivo `terraform.tfvars`.
    * **Usuário da Sessão:** O ambiente GNOME será executado sob o usuário `vduser` (ou o que você definiu em `vdi_user`).

    A primeira conexão pode demorar um pouco enquanto o ambiente gráfico é totalmente carregado.

## 🧹 Destruindo a Infraestrutura

Para remover todos os recursos criados por este Terraform e evitar custos (se estiver fora do Free Tier ou exceder os limites):
```bash
terraform destroy
