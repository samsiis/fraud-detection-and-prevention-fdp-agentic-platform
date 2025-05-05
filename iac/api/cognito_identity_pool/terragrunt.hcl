# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

dependency "cognito" {
  config_path  = "../cognito_user_pool"
  skip_outputs = true
}

dependency "client" {
  config_path  = "../cognito_user_client"
  skip_outputs = true
}

dependency "s3" {
  config_path  = "../s3_runtime"
  skip_outputs = true
}
