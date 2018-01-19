Datacube WMS on AWS ECS
=======================

The Datacube WMS ECS repository uses https://github.com/GeoscienceAustralia/terraform-ecs repository as modules for constructing and defining the AWS infrastructure.

Requirements
------------

AWS Authentication
~~~~~~~~~~~~~~~~~~
In order to run the datacube-wms terraform scripts you must be able to authenticate with AWS. This can be done in a number of different ways please see here: https://www.terraform.io/docs/providers/aws/


SSH Keypair
~~~~~~~~~~~
If you are planning to access the EC2 instances an AWS EC2 keypair must be created.

How-to
------

- In :code:`main.tf` modify the :code:`key` variable instead the :code:`terraform` :code:`backend "s3"` section. This should be unique to your project.
- In :code:`variables.tf` modify the :code:`cluster` and :code:`workspace` variables to new values that define the project or service that you are working on.
- If SSH will be used, modify the :code:`key_name` variable to the name of EC2 Key Pair that will be used.
- Update the "docker_image_registry" "latest" resource with the name of the Docker hub repo you want to run in ECS.
- Either use an existing "prod_service" "ecs" or define a new "ecs" module.
- Run :code:`terraform init`.
- If needed, import a KMS key for Chamber (see below for more details)
- Run :code:`terraform plan -out datacube-wms.plan`. This should produce a terraform plan file that can be executed.
- Run :code:`terraform apply datacube-wms.plan`. This may take some time.

Destroying Infrastructure
-------------------------

- WARNING: If using a a common KMS key for Chamber you must remove it from Terraform state or back up all data encrypted with the key before destroying with Terraform. If you do not it will be scheduled for deletion and you risk losing all data encrypted with the key. To remove from Terraform state run :code:`terraform state rm module.ecs_policy.aws_kms_key.parameter_store_key`

Using Chamber
-------------
This project recommends using chamber https://github.com/segmentio/chamber to manage secrets. Chamber can be easily built by installing :code:`golang` and running :code:`go get github.com/segmentio/chamber` also useful is AWS Vault https://github.com/99designs/aws-vault which can manage AWS authentication on your local development machine.

KMS setup
~~~~~~~~~
By default Chamber uses a KMS key with the alias :code:`parameter_store_key` to decrypt secret strings. You can check that this key and alias exists here https://console.aws.amazon.com/iam/home#/encryptionKeys/ap-southeast-2 if it does not it should be created.

Adding database password to secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In order to add or change the database password in SSM we can use chamber on the command line using the :code:`chamber write` command. For example :code:`chamber write datacube-wms db_password Password1` will write the secret `Password1` with the key `db_password` into the store for the service `datacube-wms`. If `db_password` already existed, it will be updated. We can check the secrets using :code:`chamber list -e service`.l

Docker container setup
~~~~~~~~~~~~~~~~~~~~~~

- Chamber should be compiled for the target, for datacube-wms this will be x86_64 linux. 
- Update the Docker file to include the chamber executable.
- The code which requires the decrypted secrets should be run using `chamber exec`. For datacube-wms the :code:`configure.sh` script requires the database password and chamber is on the FS at `/chamber` so we would modify the :code:`entrypoint` in the `Dockerfile` from :code:`ENTRYPOINT ["/bin/sh", "-c", "/configure.sh && /run.sh" ]` to :code:`ENTRYPOINT ["/chamber", "exec", "datacube-wms", "--", "/bin/sh", "-c", "/configure.sh && /run.sh"]` the command :code:`chamber exec datacube-wms` will retrieve all keys for the `datacube-wms` service from SSM, decrypt them, and provide them as environment variables (converting names to ALL CAPS, e.g. db_password becomes DB_PASSWORD) to the commands that follow.

Chamber with terraform
~~~~~~~~~~~~~~~~~~~~~~
Because chamber uses a single key by default, attempting to create the same key multiple times using terraform will cause errors. The :code:`terraform import` command can solve this.

- Find the ARN of the `parameter_store_key` in the AWS console. https://console.aws.amazon.com/iam/home#/encryptionKeys/ap-southeast-2
- run :code:`terraform import terraform import module.ecs_policy.aws_kms_key.parameter_store_key <$ARN here>`

Modifying
---------

The overall structure of the current datacube deployment is:

    Database - RDS
        The RDS is configured by the `database_layer` module

    Storage - EFS
        The storage system is currently automatically created by the `terraform-ecs` modules. The mounting of the EFS drive in the EC2 instances takes place using shell scripts that are set by Terraform and executed automatically by AWS. If S3 storage is desired the `terraform-ecs` modules will need to be changed.

    Networking
        Internal and external networking is provided by a number of modules such as `vpc`, `public_layer`, and `ec2_instances`

    EC2 Instances
        Using the `ec2_instances` module defines a new auto scaling group in AWS. This means that the number of ec2 instances that are started through this auto scaling group but if the instance type is changed, it is important to note that old instances will not be automatically terminated when applying a terraform plan that changes the instances.

    Jumpbox
        If `enable_jumpbox` is true a jumpbox will be created and unlike for ec2 instances setting this to false will immediately terminate the jumpbox when the plan is applied.

    Application Load Balancers
        ALBs can be created using the `load_balancer` module. Each load balancer's security group must be refered to in the `ec2_instances` module. Target groups for the ALBs must also be referenced in the `ecs` module.

    Elastic Container Service
        ECS task definitions are controlled using the `ecs` module. Currently this module requires use of the `ecs_policy` module. Each ECS definition may require it's own ALB to route traffic to the service, or ALB routing rules which are not in the scope of these modules. Currently each ECS definition also requires a JSON task definition to be created by the developer.

