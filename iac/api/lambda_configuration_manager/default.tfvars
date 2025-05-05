# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name         = "fdp-lambda-configuration"
  description  = "FDP LAMBDA CONFIGURATION"
  package_type = "Zip"    # "Image"
  architecture = "x86_64" # "arm64"
  handler      = "function.handler"
  runtime      = "python3.12"
  memory_size  = 128
  timeout      = 15
  storage_size = 512
  tracing_mode = "PassThrough"
  source_path  = "../../../app/api/configuration-manager"
  source_file  = "lib/requirements.txt"
  public       = null
  logging      = "INFO"

  sqs_managed_sse_enabled = true
  secrets_manager_ttl     = 300

  log_group_exists  = false
  retention_in_days = 5
  skip_destroy      = false
}
