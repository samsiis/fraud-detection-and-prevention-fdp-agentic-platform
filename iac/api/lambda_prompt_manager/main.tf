# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

module "lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "~> 7.0"
  function_name = format("%s-%s", var.q.name, local.fdp_gid)
  description   = var.q.description
  package_type  = var.q.package_type
  architectures = [var.q.architecture]
  handler       = var.q.handler
  runtime       = var.q.runtime
  memory_size   = var.q.memory_size
  timeout       = var.q.timeout
  tracing_mode  = var.q.tracing_mode
  store_on_s3   = true
  s3_bucket     = var.fdp_backend_bucket[data.aws_region.this.name]
  s3_prefix     = format(data.terraform_remote_state.s3.outputs.prefix, var.q.name)

  source_path = {
    path             = var.q.source_path
    pip_requirements = format("%s/%s", var.q.source_path, var.q.source_file)
    pip_tmp_dir      = "/tmp"
    patterns         = ["!venv/.*"]
  }

  create_role        = true
  attach_policies    = true
  number_of_policies = length(local.iam_policies_arns)
  policies           = local.iam_policies_arns
  role_name          = format("%s-role-%s-%s", var.q.name, data.aws_region.this.name, local.fdp_gid)
  role_path          = "/service-role/"
  policy_path        = "/service-role/"

  attach_cloudwatch_logs_policy     = true
  attach_dead_letter_policy         = true
  use_existing_cloudwatch_log_group = var.q.log_group_exists
  cloudwatch_logs_retention_in_days = var.q.retention_in_days
  cloudwatch_logs_skip_destroy      = var.q.skip_destroy
  dead_letter_target_arn            = aws_sqs_queue.this.arn
  ephemeral_storage_size            = var.q.storage_size

  environment_variables = {
    for key, value in local.env_vars :
    key => value if try(trimspace(value), "") != ""
  }
  vpc_security_group_ids = (
    var.q.public == null
    ? null : [data.terraform_remote_state.sgr.outputs.id]
  )
  vpc_subnet_ids = (
    var.q.public == null
    ? null : var.q.public == true
    ? data.terraform_remote_state.vpc.outputs.igw_subnet_ids
    : data.terraform_remote_state.vpc.outputs.nat_subnet_ids
  )
}

resource "aws_sqs_queue" "this" {
  #checkov:skip=CKV_AWS_27:This solution leverages KMS encryption using AWS managed keys instead of CMKs (false positive)

  name                    = format("%s-lambda-dlq-%s", var.q.name, local.fdp_gid)
  sqs_managed_sse_enabled = var.q.sqs_managed_sse_enabled
}
