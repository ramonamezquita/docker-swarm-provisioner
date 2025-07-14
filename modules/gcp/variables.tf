variable "region" {
  type        = string
  description = "GCP region."
}

variable "zone" {
  type        = string
  description = "GCP zone."
}


variable "project_id" {
  type        = string
  description = "GCP project."
}


variable "ssh_pub_key_file" {
  type        = string
  description = "Public key file path."
}


variable "ssh_pvt_key_file" {
  type        = string
  description = "Private key file path."
}


variable "instance_type" {
  type        = string
  default     = "e2-small"
  description = "GCP VM instace type."
}

variable "instance_count" {
  type        = number
  default     = 3
  description = "Number of instances (nodes in the cluster) to deploy."
}

