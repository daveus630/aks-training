# AKS Terraform Module

Creates an Azure Container Registry (ACR) and an Azure Kubernetes Service (AKS) cluster, and configures the required role assignments.

# Assumptions and Things You Should Know

1. The resource group provided as input variable already exists.

1. Global firewall rules have been applied (SNOW request) to allow required traffic (in/out) between the subnet where the AKS cluster will run, and the services it requires.

1. Network Security Group (NSG) of the subnet where the AKS cluster will run is configured to allow required traffic -including `kubenet`'s safe range, more on that below- (SNOW request).

1. Network Contributor role is granted to the service principal of the AKS cluster for the **network resource group**.

   > This role assignment could've been added to this module. However, adding it here means that this role assignment
   > will be managed by terraform.
   >
   > This will cause two problems if multiple clusters are created in the same subnet: 1) when doing `terraform apply`
   > and the role assignment already exists from another cluster's deployment, then Terraform will error out because
   > the resource (the role assignment) already exists; and 2) when doing `terraform destroy` and the role assignment
   > was created by this same deployment before, then Terraform will delete that role assignment, which will cause
   > other clusters in the subnet to malfunction, because they need this role assignment!
   >
   > Therefore, we decided to let that role assignment be managed OUTSIDE of Terraform, to avoid such a problem.

1. When using `azure` (i.e. Azure CNI) as network plugin, you don't have to provide any of the following: `service_cidr`, `dns_service_ip`, `pod_cidr` and `docker_bridge_cidr`.

1. When using `kubenet` as network plugin, you have to set all the following: `service_cidr`, `dns_service_ip`, `pod_cidr` and `docker_bridge_cidr`. Note that **service and pod CIDRs must not overlap with each other nor with any network element on or connected to this VNet or any VNet peered to it. In Manulife, this means the CIDRs you choose must be inside "172.29.0.0/16"**, as that is the safe range agreed upon with ETS to avoid conflict with any other Manulife network elements.

1. Although Azure documentation says you cannot create more than 1 `kubenet` cluster in a subnet, there's a workaround for that. **You must use different CIDRs in the different `kubenet` clusters that are running in the same subnet. And as per the general rule above for Manulife and `kubenet`, make sure are all CIDRs are still inside "172.29.0.0/16".**

1. The module will leave some values to their Azure defaults, most notably the following:

   1. availability zones (1,2,3)
   1. k8s version (1.18.10 when this was written but can change anytime)
   1. VMSS (always on because of availabiltiy zones)
   1. virtual nodes (off)
   1. kubernetes RBAC (on)
   1. azure AD RBAC (off)
   1. encryption at rest (platform managed key)
   1. loadbalancer sku (standard)
   1. application routing (off)
   1. private cluster (off)
   1. authorized IP ranged (off/none)
