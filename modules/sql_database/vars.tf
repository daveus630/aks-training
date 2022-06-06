variable "resource_group_name" {
  description = "The name of the resource group where the SQL server and database will be created. Must already exist."
}

variable "location" {
  description = "The location/region where the SQL server and database will be created."
}

variable "server_version" {
  description = "The version for the database server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  default     = "12.0"
}

variable "db_name" {
  description = "The name of the database to be created."
}

variable "db_edition" {
  description = "The edition of the database to be created."
  default     = "Basic"
}

variable "service_objective_name" {
  description = "The performance level for the database. For the list of acceptable values, see https://docs.microsoft.com/en-gb/azure/sql-database/sql-database-service-tiers. Default is Basic."
  default     = "Basic"
}

variable "collation" {
  description = "The collation for the database. Default is SQL_Latin1_General_CP1_CI_AS."
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "sql_admin_username" {
  description = "The administrator username of the SQL Server."
}

variable "sql_password" {
  description = "The administrator password of the SQL Server."
}

variable "vnet_subnet_id" {
  description = "The ID of the subnet that will be linked to the SQL server with a VNet rule. Must already exist."
}

variable "tags" {
  description = "The tags to associate with the SQL server and database to be created."
  type        = map(string)

  default = {
    environment = ""
    costcenter  = ""
  }
}
