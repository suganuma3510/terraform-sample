variable "region" {}
variable "name" {}
variable "env" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }
data "aws_caller_identity" "default" {}

locals {
  name_prefix = "${var.env}-${var.name}"
  account_id  = data.aws_caller_identity.default.account_id
}

terraform {
  required_version = "=v1.9.5"
}

provider "aws" {
  region = var.region
}


module "network" {
  source = "../Network/module/network"

  name      = local.name_prefix
  region    = var.region
  vpc_cidr  = var.vpc_cidr
  pub_cidrs = var.public_subnet_cidrs
  pri_cidrs = var.private_subnet_cidrs
}

module "elb" {
  source = "../ALB/module/elb"

  name           = var.name
  vpc_id         = module.network.vpc_id
  vpc_cidr       = module.network.vpc_cidr
  pub_subnet_ids = module.network.pub_subnet_ids
  # certificate_arn = module.acm.certificate_arn
}

#--------------------------------------------------------------
#  ECS
#--------------------------------------------------------------

module "ecs_cluster" {
  source = "./module/ecs_cluster"

  name = local.name_prefix
}

module "ecs_nginx" {
  source = "./module/ecs_task"

  name            = "${local.name_prefix}-nginx"
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.pri_subnet_ids
  ecs_cluster_id  = module.ecs_cluster.ecs_cluster_id
  security_groups = [module.ecs_nginx_security_group.security_group_id]
  load_balancer_config = {
    target_group_arn = module.elb.lb_tg_arn
    container_name   = "nginx"
    container_port   = 80
  }
  cpu              = 256
  memory           = 512
  desired_count    = 2
  cpu_architecture = "ARM64"
  container_definitions = templatefile("${path.module}/template/nginx_definition.json",
    {
      SERVICE_NAME    = "nginx"
      ECR_ARN         = "nginx:1.14"
      LOGS_GROUP_NAME = module.ecs_nginx_cloudwatch.log_group_name
      REGION          = var.region
  })
  task_role_arn      = module.ecs_task_role.iam_role_arn
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

module "ecs_nginx_security_group" {
  source = "./module/security_group"

  name        = "${local.name_prefix}-nginx"
  description = "ECS nginx security group for ${local.name_prefix}"
  vpc_id      = module.network.vpc_id
  ingress_cidr_blocks_rules = [
    {
      description = "HTTP access from vpc cidr"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [module.network.vpc_cidr]
    },
    {
      description = "HTTPS access from vpc cidr"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.network.vpc_cidr]
    }
  ]
}

#--------------------------------------------------------------
#  IAM
#--------------------------------------------------------------

module "ecs_exec_policy" {
  source = "./module/iam_policy"

  name = "${local.name_prefix}-ecs-task"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "ecs_task_role" {
  source = "./module/iam_role"

  name = "${local.name_prefix}-ecs-task"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ecs-tasks.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:ecs:${var.region}:${local.account_id}:*"
          },
          "StringEquals" : {
            "aws:SourceAccount" : local.account_id
          }
        }
      }
    ]
  })
  iam_policies = [
    "CloudWatchAgentServerPolicy",
    module.ecs_exec_policy.iam_policy_name
  ]
  depends_on = [module.ecs_exec_policy]
}

module "ecs_task_execution_role" {
  source = "./module/iam_role"

  name = "${local.name_prefix}-ecs-task-execution"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  iam_policies = [
    "AmazonSSMReadOnlyAccess",
    "AmazonECSTaskExecutionRolePolicy",
    "CloudWatchAgentServerPolicy",
  ]
}

module "ecs_nginx_cloudwatch" {
  source = "./module/cloudwatch"

  log_group_name = "/ecs/${local.name_prefix}-nginx"
}
