provider "aws" {
  region = var.region
}

resource "aws_emr_cluster" "cluster" {

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true
  name                              = "${var.name}-${var.environment}"
  release_label                     = var.release_label
  applications                      = var.applications
  service_role                      = aws_iam_role.service_role.id

  ec2_attributes {
    key_name                          = var.key_name
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = aws_security_group.emr_master_sg.id
    emr_managed_slave_security_group  = aws_security_group.emr_core_sg.id
    instance_profile                  = aws_iam_instance_profile.emr_instance_profile.id
  }

  ## Fleet configuration for autoscaling
  master_instance_fleet {
    instance_type_configs {
      instance_type = var.master_instance_type
      ebs_config {
        size                 = 100
        type                 = "gp2"
        volumes_per_instance = 1
      }
    }
    target_on_demand_capacity = var.master_target_on_demand_capacity
  }

  core_instance_fleet {
    instance_type_configs {
      instance_type                              = var.primary_instance_type
      weighted_capacity                          = var.primary_instance_type_weighted_capacity
      bid_price_as_percentage_of_on_demand_price = 100

      ebs_config {
        size                 = 100
        type                 = "gp2"
        volumes_per_instance = 1
      }
    }

    instance_type_configs {
      instance_type                              = var.secondary_instance_type
      weighted_capacity                          = var.secondary_instance_type_weighted_capacity
      bid_price_as_percentage_of_on_demand_price = 75

      ebs_config {
        size                 = 100
        type                 = "gp2"
        volumes_per_instance = 1
      }
    }

    launch_specifications {
      spot_specification {
        allocation_strategy      = "capacity-optimized"
        block_duration_minutes   = 0
        timeout_action           = "SWITCH_TO_ON_DEMAND"
        timeout_duration_minutes = 10
      }
    }

    name                      = "core fleet"
    target_on_demand_capacity = var.core_target_on_demand_capacity
    target_spot_capacity      = var.core_target_spot_capacity
  }

  configurations_json = <<EOF
  [
   {
      "Classification":"spark-hive-site",
      "Properties":{
         "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      }
   },
   {
      "Classification":"hive-site",
      "Properties":{
         "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      }
   },
   {
      "Classification":"spark",
      "Properties":{
         "maximizeResourceAllocation":"true"
      }
   },
   {
      "Classification":"spark-env",
      "Configurations":[
         {
            "Classification":"export",
            "Properties":{
               "PYSPARK_PYTHON":"/usr/bin/python3"
            }
         }
      ]
   },
   {
    "Classification": "yarn-site",
    "Properties": {
      "yarn.nodemanager.aux-services": "mapreduce_shuffle,spark_shuffle",
      "yarn.nodemanager.aux-services.spark_shuffle.class": "org.apache.spark.network.yarn.YarnShuffleService",
      "yarn.nodemanager.vmem-check-enabled": "false",
      "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler",
      "yarn.scheduler.fair.preemption": "true",
      "yarn.scheduler.fair.user-as-default-queue": "false",
      "yarn.log-aggregation-enable": "true",
      "yarn.log-aggregation.retain-seconds": "-1",
      "yarn.nodemanager.remote-app-log-dir": "${var.yarn_logs}/${var.environment}/"
    }
  }
]
EOF

  log_uri                = var.log_uri
  step_concurrency_level = var.max_concurrent_steps

  #Enable Hadoop Debugging (Yarn)
  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "Setup Hadoop Debugging"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }

  lifecycle {
    ignore_changes = [step]
  }

  tags = {
    environment = var.environment
    Name        = "${var.name}-${var.environment}"
  }
}

resource "aws_emr_managed_scaling_policy" "emr_scaling_policy" {
  cluster_id = aws_emr_cluster.cluster.id

  compute_limits {
    unit_type                       = "InstanceFleetUnits"
    minimum_capacity_units          = var.min_total_capacity
    maximum_capacity_units          = var.max_total_capacity
    maximum_ondemand_capacity_units = var.max_on_demand_capacity
    maximum_core_capacity_units     = var.max_core_capacity
  }
}
