terraform-aws-cf-net
====================

NOTE: **If you are looking to deploy Cloud Foundry into AWS VPC, visit https://github.com/cloudfoundry-community/terraform-aws-cf-install.**

This repository is a submodule of the project above that aims to create one click deploy for Cloud Foundry on AWS VPC. You *probably* don't want to use this repo directly.

This terraform module creates a VPC, a set of public/private subnets and a NAT for outbound traffic.

Architecture
------------

We use https://github.com/cloudfoundry-community/terraform-aws-vpc to create the VPC, bastion subnet, microbosh subnet, and NAT server. This repo is responsible for creating the loadbalancer and runtime subnets, security groups, and and the elastic IP that will be used by the Cloud Foundry API.

The idea is that you can use this terraform module multiple times, setting the`offset` variable differently each time, and you'll get a complete sett of the subnets, sgs, and EIPs necessary for a separate CF instance.

Create resources needed by Cloud Foundry
----------------------------------------

### Prerequisites

The one step that isn't automated is the creation of SSH keys. Waiting for feature to be added to terraform. An AWS SSH Key need to be created in desired region prior to running the following commands.

**NOTE**: You **must** being using at least terraform 0.3.1 for the tags to work.

### Running terraform

```bash
mkdir terraform-aws-cf
cd terraform-aws-cf
terraform apply github.com/cloudfoundry-community/terraform-aws-cf
```

Subnets
-------

Subnets created take the form of the `network` variable (for example, 10.10), appended with the `offset` variable (0 by default, can be anything up to 25), and then the rest of the CIDR. For example, with `network` as 10.10 and `offset` as 5, the runtime 2a subnet would be `10.10.53.0/24`. Note that there is a single bastion subnet and bosh subnet per VPC - there is no need to have multiple, no matter how many Cloud Foundry instances you're running. As such, they do not take the `offset` variable - they will always be X.X.0.0/24 and X.X.1.0/24 respectively.

| Name         | CIDR        | Created By           |
|--------------|-------------|----------------------|
| Bastion      | X.X.0.0/24  | terraform-aws-vpc    |
| Microbosh    | X.X.1.0/24  | terraform-aws-vpc    |
| Loadbalancer | X.X.x2.0/24 | terraform-aws-cf-net |
| Runtime 2a   | X.X.x3.0/24 | terraform-aws-cf-net |
| Runtime 2b   | X.X.x4.0/24 | terraform-aws-cf-net |
