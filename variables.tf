variable "gcp_project_id" {
    type = string
    default = ""
}

variable "gcp_vpc_network" {
    type = string
    default = ""
}

variable "terraform_state_bucket" {
  type = string
  default = ""
}

variable "gcp_region" {
    type = string
    default = ""
}

variable "gcp_zone" {
    type = string
    default = ""
}

variable "repo_name" {
    type = string
    default = ""
}

variable "container_port" {
    type = number
    default = 5000
}

variable "docker_image" {
    type = string
    default = ""
}

# Serveless VPC Access connection
variable "gcp_serverless_vpc_subnet" {
    type = string
    default = "192.168.100.0/28"
}

variable "gcp_serverless_machine_type" {
    type = string
    default = "e2-standard-4"
}

variable "gcp_serverless_min_instances" {
    type = number
    default = 2
}

variable "gcp_serverless_max_instances" {
    type = number
    default = 3
}