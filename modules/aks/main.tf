# Configure Terraform provider and version required
terraform {
  required_providers {
    azurerm = {
      version = "=2.69.0"
      source  = "hashicorp/azurerm"
    }
  }
}

# Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_name}-dns"
  sku_tier            = var.aks_sku_tier
  kubernetes_version  = "1.21.7"

  default_node_pool {
    name                 = "agentpool"
    node_count           = var.node_count
    max_pods             = var.max_pods_per_node
    vm_size              = var.node_vm_size
    vnet_subnet_id       = var.vnet_subnet_id
    orchestrator_version = "1.21.7"
  }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy

    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    pod_cidr           = var.pod_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
    outbound_type      = var.outbound_type
  }

  addon_profile {
    azure_policy {
      enabled = true
    }
    kube_dashboard {
      enabled = false
    }
  }

  tags = var.tags
}

# Capture the ID of the service principal the AKS cluster will use to authenticate
data "azuread_service_principal" "aks_principal" {
  application_id = var.service_principal_client_id
}

# Grant AcrPull role to the service principal of the AKS cluster for the ACR
# This will allow the AKS cluster to pull images from the ACR
# Reference the ACR resource DIRECTLY so that Terraform creates it before this
resource "azurerm_role_assignment" "acr_role1" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azuread_service_principal.aks_principal.id
}

# Grant Storage Account Contributor role to the service principal of the AKS cluster for the resource group 
# This will allow the cluster to access Disk/Storage resources in the resource group
resource "azurerm_role_assignment" "acr_role2" {
  scope                = var.resource_group_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_service_principal.aks_principal.id
}
