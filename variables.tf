variable "gcp_project_id" {
    type = string
    default = "eternal-empire-465908-c3"
}

variable "gcp_region" {
    type = string
    default = "us-east1"
}

variable "gcp_zone" {
    type = string
    default = "us-east1-a"
}

variable "repo_name" {
    type = string
    default = "my-repository"
}

variable "container_port" {
    type = number
    default = 5000
}

variable "docker_image" {
    type = string
    default = ""
}