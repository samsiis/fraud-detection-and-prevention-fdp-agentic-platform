# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  s3_origin_id   = format("%s-origin",
    data.terraform_remote_state.s3.outputs.id
  )
}
