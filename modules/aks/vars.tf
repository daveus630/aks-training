variable "resource_group_name" {
  description = "The name of the resource group where AKS and ACR will be created. Must already exist."
}

variable "resource_group_id" {
  description = "The ID of the resource group where AKS and ACR will be created. Must already exist."
}

variable "location" {
  description = "The location/region where the resources will be created."
}

variable "outbound_type" {
  description = "Possible values are loadBalancer and userDefinedRouting. Defaults to userDefinedRouting."
  default     = "loadBalancer"
}

variable "acr_name" {
  description = "The name of the ACR to be created."
}

variable "vnet_subnet_id" {
  description = "The ID of the subnet where the AKS cluster will run. Must already exist."
}

variable "aks_name" {
  description = "The name of the AKS cluster to be created."
}

variable "aks_sku_tier" {
  description = "The SKU Tier to use for the AKS cluster. \"Free\" or \"Paid\" - the latter includes an uptime SLA."
  default     = "Free"
}

variable "node_count" {
  description = "The number of nodes in the node pool of the cluster. 1 for dev/tst, minimum 3 for production."
}

variable "max_pods_per_node" {
  description = "The maximum number of Pods per node. 10-250 for Azure CNI, 10-110 for kubenet."
}

variable "node_vm_size" {
  description = "The VM size to use for the node pool of the cluster."
  default     = "Standard_D2_v2"
}

variable "service_principal_client_id" {
  description = "The client ID of the service principal that will be used to authenticate the AKS cluster. Must already exist."
}

variable "service_principal_client_secret" {
  description = "The client secret of the service principal that will be used to authenticate the AKS cluster. Must already exist."
}

variable "network_plugin" {
  description = "The network plugin to use for the AKS Cluster. \"azure\" or \"kubenet\"."
}

variable "network_policy" {
  description = "The network plugin to use for the AKS Cluster. \"calico\", \"azure\" or don't assign it. \"calico\" is the current standard at Manulife."
  default     = "calico"
}

variable "service_cidr" {
  description = "The network range used by the Kubernetes internal services. Only for kubenet."
  default     = null
}

variable "dns_service_ip" {
  description = "The IP address by the cluster DNS/service discovery. This should be the .10 address of the service CIDR. Only for kubenet."
  default     = null
}

variable "pod_cidr" {
  description = "The network range used to assign IP addresses to Pods. Each node in the cluster will require a /24 slice of this, so it must be large enough to accommodate the number of nodes you choose. Only for kubenet."
  default     = null
}

variable "docker_bridge_cidr" {
  description = "The network range used as the Docker bridge IP address on nodes. You can use \"172.17.0.1/16\" (default value taken from Azure Portal) since this is typically not even used. Only for kubenet."
  default     = null
}

variable "tags" {
  description = "The tags to associate with the AKS cluster."
  type        = map(string)

  default = {
    environment = ""
    costcenter  = ""
  }
}
