variable "cluster" {
  default = "datacube-wms"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "workspace" {
  default = "dev"
}

variable "owner" {
  default = "DEA"
}

variable "name" {
  type        = "string"
  description = "Name of the service"
}

variable "docker_image" {
  type        = "string"
  description = "docker image to run"
}

variable "health_check_path" {
  default     = "/?version=1.3.0&request=GetCapabilities&service=WMS"
  description = "A path that returns 200OK if container is healthy"
}

variable "memory" {
  default     = 1024
  description = "memory for the container in MB"
}

variable "alb_name" {
  default     = "default"
  description = "The name of the loadbalancer"
}

# =============================
# Networking
variable "availability_zones" {
  type    = "list"
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "public_subnet_cidrs" {
  type    = "list"
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  default = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

variable "ssh_ip_address" {
  type    = "string"
  default = "127.0.0.1/32"
}

variable "key_name" {
  type    = "string"
  default = ""
}

variable "enable_jumpbox" {
  default = true
}

variable "enable_nat" {
  default = false
}

variable "enable_gateways" {
  default = false
}

variable "public_subnet_ids" {
  type        = "list"
  default     = ["subnet-e42eeabc", "subnet-3d324f74", "subnet-e6b2f281"]
  description = "List of public subnet ids to place the loadbalancer in"
}

variable "vpc_id" {
  description = "The VPC id"
  default     = "vpc-5472fd33"
}

# ==================
# Containers
variable "container_port" {
  default = 8000
}

# variable "container" {
#   type = "string"
#   default = "geoscienceaustralia/datacube-wms:latest"
#   description = "Docker container address. e.g. geoscienceaustralia/datacube:latest"
# }

# ==================
# Services and Tasks
variable "task_desired_count" {
  default = 1
}

# ==================
# database

