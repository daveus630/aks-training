# Configure Terraform provider and version required
terraform {
  required_providers {
    azurerm = {
      version = "=2.69.0"
      source  = "hashicorp/azurerm"
    }
  }
}

# Create an Azure SQL Server "singleton" instance 
resource "azurerm_sql_server" "sqlsvr" {
  name                         = "sqlsvr-${var.db_name}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.server_version
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_password
  tags                         = var.tags
}

# Create a VNet rule between the SQL server and the subnet
# Reference the SQL server resource DIRECTLY so that Terraform creates it before this
resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
  name                = "sql-vnet-rule"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sqlsvr.name
  subnet_id           = var.vnet_subnet_id
}

# Create an Azure SQL DB in the server (that's just how it works)
# Reference the SQL server resource DIRECTLY so that Terraform creates it before this
resource "azurerm_sql_database" "sqldb" {
  name                             = var.db_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  edition                          = var.db_edition
  collation                        = var.collation
  server_name                      = azurerm_sql_server.sqlsvr.name
  create_mode                      = "Default"
  requested_service_objective_name = var.service_objective_name
  tags                             = var.tags
}
