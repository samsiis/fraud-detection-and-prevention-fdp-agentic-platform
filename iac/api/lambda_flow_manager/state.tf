# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn" {
  value = module.lambda.lambda_function_arn
}

output "invoke_arn" {
  value = module.lambda.lambda_function_invoke_arn
}

output "qualified_arn" {
  value = module.lambda.lambda_function_qualified_arn
}

output "qualified_invoke_arn" {
  value = module.lambda.lambda_function_qualified_invoke_arn
}

output "signing_job_arn" {
  value = module.lambda.lambda_function_signing_job_arn
}

output "signing_profile_version_arn" {
  value = module.lambda.lambda_function_signing_profile_version_arn
}

output "last_modified" {
  value = module.lambda.lambda_function_last_modified
}

output "source_code_size" {
  value = module.lambda.lambda_function_source_code_size
}

output "version" {
  value = module.lambda.lambda_function_version
}

output "function_name" {
  value = module.lambda.lambda_function_name
}
