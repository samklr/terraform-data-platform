
module "emr" {
  source        = "../../../terraform-modules/emr"
  name          = "data-stack"
  environment   = "dev"
  release_label = "emr-6.2.0"
  aws_account_id = "000000000L2"

  applications = ["Spark", "Hadoop", "Hive"]

  vpc_id    = "vpc-*****"
  subnet_id = "subnet-****"
  key_name  = "ssh-emr"

  #security group to access redshift dev
  redshift_emr_sg_id = "sg-red-emr"

  master_instance_type = "m5.xlarge"

  #Instances Types and configurations for core nodes
  primary_instance_type                   = "m5.xlarge"
  primary_instance_type_weighted_capacity = 1

  secondary_instance_type                   = "m5.2xlarge"
  secondary_instance_type_weighted_capacity = 2

  # EMR Fleet Target for provisionning
  master_target_on_demand_capacity = 1
  core_target_on_demand_capacity   = 1
  core_target_spot_capacity        = 1

  #EMR Managed Autoscaling in FleetUnits applies to core nodes
  min_total_capacity     = 1
  max_total_capacity     = 8
  max_on_demand_capacity = 1
  max_core_capacity      = 8

  log_uri              = "s3n://sk-datalake-dev-logs"
  yarn_logs            = "s3n://sk-datalake-dev-yarn-logs"
  max_concurrent_steps = 2
}
