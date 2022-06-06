# This is your Terraform root module
terraform {
  required_providers {
    azurerm = {
      version = "=2.69.0"
      source  = "hashicorp/azurerm"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-muaks-tfstate-dev"
    storage_account_name = "stmuakstfstatedev"
    container_name       = "container-muaks-tfstate-dev"
    key                  = "sunicda.terraform.tfstate"
    access_key           = "kqFUi/Rj7jzLNhNqCEo7Ys7HAON2y4OYhv7atU68yJhrO9dPK/HpRmpeALOYc8vEcZuzV+1BRlCfozsCa4p3vw=="
  }
}
provider "azurerm" {
  features {}
  subscription_id = "4f0724ed-84bd-4977-97a8-8554a4d17b0c"
}

locals {
  # this resource group will be created here
  resource_group_name = "rg-muaks-sunicda-dev"
  location            = "canadacentral"
  tags = {
    environment = "dev"
    CostCenter  = "6662"
  }
  # this subnet, vnet and resource group must already exist (managed by ETS, not us)
  vnet_subnet_name         = "PaaS01"
  vnet_name                = "VNET-CAC-MU_AKS-Sandbox-PaaS-01"
  vnet_resource_group_name = "CAC-MU_AKS-Sandbox-network"
}
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}
# Capture the subnet ID where the AKS cluster will run and the SQL server will have a VNet rule
data "azurerm_subnet" "subnet" {
  name                 = local.vnet_subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = local.vnet_resource_group_name
}
module "sql-database" {
  source              = "./modules/sql_database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  db_name             = "sqldb-muaks-sunicda-dev"
  sql_admin_username  = "mradministrator"
  sql_password        = "sunicdaM738l$sm$k293PLK"
  vnet_subnet_id      = data.azurerm_subnet.subnet.id
  tags                = local.tags
}
module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_id   = azurerm_resource_group.rg.id
  location            = "canadacentral"
  acr_name            = "acrmuakssunicdadev"
  aks_name            = "aks-muaks-sunicda-dev"
  vnet_subnet_id      = data.azurerm_subnet.subnet.id
  node_count          = 2
  max_pods_per_node   = 110
  node_vm_size        = "Standard_D2_v2"

  service_principal_client_id     = "e53b4a8b-0eec-441b-aacb-936ff93f4093"
  service_principal_client_secret = "-xO7Q~jSVG_1SeWsT.tr088RddZkQGJEVV14f"

  network_plugin     = "kubenet"
  service_cidr       = "172.29.13.0/24"
  dns_service_ip     = "172.29.13.10"
  pod_cidr           = "172.29.128.0/21"
  docker_bridge_cidr = "172.17.0.1/16"

  tags = local.tags
}

