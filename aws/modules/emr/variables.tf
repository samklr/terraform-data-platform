variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  default = "staging"
}

variable "aws_account_id" {}

variable "name" {
  default = "platform"
}

variable "vpc_id" {}

variable "redshift_emr_sg_id" {}

variable "release_label" {
  default = "emr-6.2.0"
}

variable "applications" {
  default = ["Hadoop", "Spark"]
  type    = list(string)
}

variable "key_name" {}

variable "subnet_id" {}

variable "ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "master_instance_type" {}

variable "primary_instance_type" {}

variable "primary_instance_type_weighted_capacity" {}

variable "secondary_instance_type" {}

variable "secondary_instance_type_weighted_capacity" {}

variable "master_target_on_demand_capacity" {
  default = 1
}

variable "core_target_on_demand_capacity" {
  default = 1
}

variable "core_target_spot_capacity" {
  default = 1
}

variable "max_total_capacity" {}

variable "min_total_capacity" {}

variable "max_on_demand_capacity" {}

variable "max_core_capacity" {}

variable "log_uri" {}

variable "yarn_logs" {}

variable "max_concurrent_steps" {
  default = 1
}
