# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  bucket              = "fdp-runtime"
  force_destroy       = true
  object_ownership    = "BucketOwnerPreferred"
  object_lock_enabled = false
  object_lock_mode    = null # "COMPLIANCE"
  object_lock_days    = 36500
  object_lock_retain  = "2345-12-31T23:59:59Z"
  sse_algorithm       = "AES256" # "aws:kms"
  versioning_status   = "Enabled"
  logs_prefix         = "s3_runtime_logs/"
  assume_role_name    = "fdp-cicd-assume-role"
}
