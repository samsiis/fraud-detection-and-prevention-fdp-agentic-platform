# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "auth" {
  config_path  = "../cognito_user_domain"
  skip_outputs = true
}

dependency "cognito" {
  config_path  = "../cognito_user_pool"
  skip_outputs = true
}

dependency "iam_logs" {
  config_path  = "../iam_role_agw_logs"
  skip_outputs = true
}

dependency "iam_sqs" {
  config_path  = "../iam_role_agw_sqs"
  skip_outputs = true
}

dependency "lambda_agent" {
  config_path  = "../lambda_agent_manager"
  skip_outputs = true
}

dependency "s3" {
  config_path  = "../s3_runtime"
  skip_outputs = true
}
