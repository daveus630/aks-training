# Azure SQL DB "Singleton" Terraform Module

Creates a SQL server and a SQL db (aka Azure SQL DB "Singleton"), and configures a VNet rule between the server and an existing subnet (that subnet is where requests to the DB will be made, e.g. VM/AKS/...).

# Assumptions and Things You Should Know

1. The resource group provided as input variable already exists.

1. Network Security Group (NSG) of the subnet where requests to the DB will be made has open outbound to the Sql.$region service at port 1433.

1. The subnet to which the VNet rule will be created has a configured Service Endpoint of type `Microsoft.Sql`.
