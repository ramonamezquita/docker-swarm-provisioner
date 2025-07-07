variable "region" {
  type    = string
  default = "europe-north2"
}

variable "zone" {
  type    = string
  default = "europe-north2-a"
}


variable "project_id" {
  type = string
}


variable "ssh_pub_key_file" {
  type = string
}


variable "ssh_pvt_key_file" {
  type = string
}


variable "instance_type" {
  type    = string
  default = "e2-small"
}

variable "instance_count" {
  type    = number
  default = 3
}

