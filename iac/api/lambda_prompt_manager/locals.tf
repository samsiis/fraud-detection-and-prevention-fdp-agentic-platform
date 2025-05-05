# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  fdp_gid = (
    try(trimspace(var.fdp_gid), "") == ""
    ? data.terraform_remote_state.s3.outputs.fdp_gid
    : var.fdp_gid
  )
  env_vars = {
    FDP_LOGGING         = var.q.logging
    FDP_ID              = local.fdp_gid
    FDP_ACCOUNT         = data.aws_caller_identity.this.account_id
    FDP_REGION          = data.aws_region.this.name
    FDP_CHECK_REGION    = data.terraform_remote_state.s3.outputs.region2
    FDP_API_URL         = data.terraform_remote_state.auth.outputs.api_url
    FDP_AUTH_URL        = data.terraform_remote_state.auth.outputs.auth_url
    FDP_SECRETS         = data.aws_secretsmanager_secret.this.name
    SECRETS_MANAGER_TTL = var.q.secrets_manager_ttl
  }
  iam_policies_arns = [
    "arn:${data.aws_partition.this.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:${data.aws_partition.this.partition}:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
}
