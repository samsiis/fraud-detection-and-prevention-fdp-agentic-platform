# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = format("%s-%s", var.q.name, local.fdp_gid)
  allow_unauthenticated_identities = var.q.allow_unauthenticated_identities
  allow_classic_flow               = var.q.allow_classic_flow

  cognito_identity_providers {
    client_id               = data.terraform_remote_state.client.outputs.api
    provider_name           = data.terraform_remote_state.cognito.outputs.endpoint
    server_side_token_check = var.q.server_side_token_check
  }

  cognito_identity_providers {
    client_id               = data.terraform_remote_state.client.outputs.web
    provider_name           = data.terraform_remote_state.cognito.outputs.endpoint
    server_side_token_check = var.q.server_side_token_check
  }
}
