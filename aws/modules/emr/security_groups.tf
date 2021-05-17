
resource "aws_security_group" "emr_master_sg" {
  name                   = "emr-master-${var.environment}"
  description            = "Security group for EMR master."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "emr_core_sg" {
  name                   = "emr-core-${var.environment}"
  description            = "Security group for EMR slaves."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "emr_master_redshift" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master_sg.id
  security_group_id        = var.redshift_emr_sg_id
}

resource "aws_security_group_rule" "emr_core_redshift" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_core_sg.id
  security_group_id        = var.redshift_emr_sg_id
}
