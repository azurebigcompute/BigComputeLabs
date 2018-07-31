# BigComputeLabs
Big Compute Learning Labs 

## Azure CycleCloud Labs

### Introduction

These are technical labs to help you get started using CycleCloud to create, use, and manage Azure HPC clusters. 

#### Objectives
In these labs, you will:

- Understand Azure Resource Manager templates and versioning.
- Use Azure Resource Manager version profiles to install PowerShell
- Create an Azure resource group and deploy an Azure Resource Manager template.
- Use the Azure Stack Policy module to constrain the resource group and test the limits of the constrained resource group.
- Use the Azure Stack template validator to identify versioning incompatibilities.
- Update templates for Azure Stack.

* setup and install CycleCloud on a VM using an ARM template
* configure CycleCloud to use Azure credentials
* create a simple HPC cluster consisting of a job scheduler and an NFS file server
* submit jobs and observe the cluster autoscale up and down automatically
* review CycleCloud's cost reporting & controls, reporting, and other features

Resources can be located at the end of the Lab, as well as links for more advanced topics. These labs should take no more than 60-120 minutes to complete per lab, and many much faster than that.

We welcome any thoughts or feedback. We are always looking for ways to improve the experience of learning Azure CycleCloud!

#### Azure CycleCloud

Azure CycleCloud provides a simple, secure, and scalable way to manage compute and storage resources for HPC workloads in Microsoft Azure. Azure CycleCloud enables users to create environments for workloads on any point of the parallel and distributed processing spectrum, from parallel workloads to tightly-coupled applications such as MPI jobs on Infiniband/RDMA. By managing resource provisioning, configuration, and monitoring, Azure CycleCloud allows users and IT staff to focus on business needs instead infrastructure.

Azure CycleCloud delivers:

* Complete control over compute environments, including VM resources, storage, networking, and the full application stack
* Data transfer and management tools
* Role-based access control (RBAC)
* Templated applications and reference architectures
* Cost reporting and controls
* Monitoring and alerting
* Automated, customizable configuration
* Consistent security and encryption

If this is your first time using Azure CycleCloud, we recommend reading the [product documentation](https://review.docs.microsoft.com/en-us/azure/cyclecloud) to get more familiar with common Azure CycleCloud concepts: clusters, nodes and node arrays, data management, etc. Azure CycleCloud is freely available, downloadable, packaged, licensed application. For support options or other general questions, email askcyclecloud @ microsoft.com.

#### Intended audience

This lab is intended for people who would like to learn how to use Azure CycleCloud to create, customize, and manage HPC environments in Azure.

#### Labs

- [ ] 1. [01 - Setup CycleCloud with ARM](/CycleCloud/01-Setup%20CycleCloud%20with%20ARM/README.md)
- [ ] 2. [02 - Creating a Simple Autoscaling HPC Cluster](/CycleCloud/02-Creating%20a%20Simple%20Autoscaling%20HPC%20Cluster/README.md)


## Prerequisites

- Azure subscription (You can sign up for a free account here.)

## Contributing

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
