# Cantaloupe Terraform Deployment

## Prerequisites for using docker-cantaloupe terraform
In order to deploy successfully, you'll need the following prerequisites:
  * Terraform Enterprise (Free/Paid) Account
    * Create an organization or use your own account name as your organization
  * Terraform Enterprise (Free Tier) Token
    * Generate a user token from: https://app.terraform.io/app/settings/tokens
  * Create a `backend.hcl` file by replacing the values found in the `backend.hcl.sample` file
  * The [Terraform software](https://www.terraform.io/downloads.html) installed on your machine.
  * Supply a prefix to name your AWS resources with. Usually an alias similar to your username will suffice
    * `ephemeral_app_name = "joebruin"`
  * VPC Setup
    * This setup assumes you have no VPC set up. We want the ephemeral environments isolated from existing resources
    * The default setup will create a `10.0.0.0/16` VPC network and a `10.0.1.0/24` subnet allocated to the created region. If you're not sure what to do here, its suggested you leave this alone unless you have conflicting IP spaces in your AWS environment
    * OPTIONAL: If you want to override and of the existing VPC configurations, you'll need to supply this information. Note that you'll need to 
      * The following example will create a `10.1.0.0/16` VPC network and 2 subnets in different AZ zones in the same region `10.1.1.0/24` and `10.1.2.0/24`:
      * `vpc_cidr_block    = 10.1.0.0/16`
      * `subnet_init_value = 1`
      * `subnet_count      = 2`
  * Security Group Configuration
    * Supply the port in which your application runs on. There is no port forwarding allowed in Fargate setups
      * `ingress_port = [8181, 8182]`
    * Supply what networks and/or IPs you want to allow access to your Fargate container
      * `ingress_allowed = [0.0.0.0/16]`
    * OPTIONAL: If you have more restrictive needs and only want to allow AWS resources to access your containers, you can define the IDs of the resources in the following:
      * `sg_groups = ["${aws_lb.main.id}"]`
  * Private Image Registry Access
    * If you are accessing an image from a private registry, you'll need to store the username and password credentials in AWS Secrets Manager. After storing the secrets, you'll need to login to the IAM console, retrieve the ARN and supply it to this terraform deployment
      * `dockerhub_credentials_secrets_arn = "arn:aws:secretsmanager:us-west-2:0123456789:secret:dockerhubauth-example"`
      * You can usually find these ARNs by accessing the following this [URL](https://us-east-1.console.aws.amazon.com/secretsmanager/home?region=us-east-1#/listSecrets). Note that you may need to change the region as this URL is region specific.
  * Cantaloupe Container Definitions
    * Fargate Specifications
      * OPTIONAL: `memory = "2048"`
      * OPTIONAL: `cpu = "1024"`
      * OPTIONAL: `enable_load_balancer = 0`
      * OPTIONAL: `container_count = 1`
      * `image_url = registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1`
      * `listening_port = 8181`
      * `disable_load_balancer = 1`
    * Environment Variables supplied to container
      * The current templates sets up the following environment variables. These variables are rendered in `templates/env_vars.properties.tpl`. If you want to add more environment variables to pass into the container, please create a new template file or modify the existing. For values to set, you'll want to refer to the cantaloupe properties example. An example can be found [here](https://github.com/UCLALibrary/docker-cantaloupe/blob/master/configs/cantaloupe.properties.default-4.1.3).
        * `cantaloupe_enable_admin`
        * `cantaloupe_admin_secret`
        * `cantaloupe_enable_cache_server`
        * `cantaloupe_cache_server_derivative`
        * `cantaloupe_cache_server_derivative_ttl`
        * `cantaloupe_cache_server_purge_missing`
        * `cantaloupe_processor_selection_strategy`
        * `cantaloupe_manual_processor_jp2`
        * `cantaloupe_s3_cache_access_key`
        * `cantaloupe_s3_cache_secret_key`
        * `cantaloupe_s3_cache_endpoint`
        * `cantaloupe_s3_cache_bucket`
        * `cantaloupe_s3_source_access_key`
        * `cantaloupe_s3_source_secret_key`
        * `cantaloupe_s3_source_endpoint`
        * OPTIONAL: `cantaloupe_s3_source_bucket` Modifying this will configure cantaloupe to use the specified bucket
        * `cantaloupe_s3_source_basiclookup_suffix`
        * `cantaloupe_source_static`
        * `cantaloupe_heapsize`


## Launching private cantaloupe image with preconfigured S3 bucket
Create `terraform.tfvars` in this directory
```
# Naming prefix
ephemeral_app_name = "joebruin"

# VPC Variables
vpc_cidr_block            = "10.10.0.0/16"
subnet_init_value         = 1
subnet_count              = 1

# Firewall Setup
ingress_port    = [8181, 8182]
ingress_allowed = ["0.0.0.0/0"]

# Cantaloupe Container Definitions
memory                            = "2048"
cpu                               = "1024"
image_url                         = "registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1"
listening_port                    = 8182
disable_load_balancer             = 1
dockerhub_credentials_secrets_arn = "arn:aws:secretsmanager:us-west-2:0123456789:secret:dockerhub-auth-example"

# Cantaloupe Container Environment Variables
cantaloupe_admin_secret                 = "enteryouradminpassword"
cantaloupe_s3_source_access_key         = "s3_access_key"
cantaloupe_s3_source_secret_key         = "s3_secret_key"
cantaloupe_s3_source_endpoint           = "s3_endpoint"
cantaloupe_s3_source_bucket             = "s3_bucket"
cantaloupe_s3_source_basiclookup_suffix = ".jpx"
cantaloupe_source_static                = "S3Source"
cantaloupe_heapsize                     = "2g"

```

## Launching private cantaloupe image with auto-created S3 bucket
Create `terraform.tfvars` in this directory
```
# Naming prefix
ephemeral_app_name = "joebruin"

# VPC Variables
vpc_cidr_block            = "10.10.0.0/16"
subnet_init_value         = 1
subnet_count              = 1

# Firewall Setup
ingress_port    = [8181, 8182]
ingress_allowed = ["0.0.0.0/0"]

# Cantaloupe Container Definitions
memory                            = "2048"
cpu                               = "1024"
image_url                         = "registry.hub.docker.com/uclalibrary/cantaloupe-ucla:4.1.1"
listening_port                    = 8182
disable_load_balancer             = 1
dockerhub_credentials_secrets_arn = "arn:aws:secretsmanager:us-west-2:0123456789:secret:dockerhub-auth-example"

# Cantaloupe Container Environment Variables
cantaloupe_admin_secret                 = "enteryouradminpassword"
cantaloupe_s3_source_access_key         = "s3_access_key"
cantaloupe_s3_source_secret_key         = "s3_secret_key"
cantaloupe_s3_source_endpoint           = "s3_endpoint"
cantaloupe_s3_source_basiclookup_suffix = ".jpx"
cantaloupe_source_static                = "S3Source"
cantaloupe_heapsize                     = "2g"

```

## Running the Terraform Deployment
To deploy cantaloupe ephemeral environment after configuring `terraform.tfvars`
```
bin/run
```

To destroy cantaloupe ephemeral environment
```
bin/run destroy
```

## Visible AWS Resource names
With the defined prefix provided earlier, you should be able to see the following resources created in AWS. It is recommended that you login to your IAM console and verify that these exists.
```
  fargate_ecs_role_name    = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-ecs-role"
  fargate_cluster_name     = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-cluster"
  fargate_service_name     = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-service"
  fargate_definition_name  = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-definition"
  cantaloupe_s3_src_bucket = "${var.ephemeral_app_name}-cantaloupe-ephemeral-src-bucket"
  sg_name                  = "${var.ephemeral_app_name}-cantaloupe-ephemeral-security-group"
```

## Retrieving the public IP of your deployed container in Fargate
Terraform will output the public IP of your Fargate Cantaloupe container in the output. If you missed this, the IP is stored in file called `cantaloupe_ip`.
