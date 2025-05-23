# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

q = {
  name         = "fdp-transaction"
  hash_key     = "pk"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  stream_enabled         = true
  stream_view_type       = "NEW_AND_OLD_IMAGES"
  point_in_time_recovery = true
  encryption_enabled     = true
  ttl_enabled            = false
  ttl_attribute_name     = "ttl_time"
}

# Not Supported Regions for DynamoDB Global Tables
# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GlobalTables.html#GlobalTablesReplicate
# https://aws.amazon.com/about-aws/whats-new/2023/09/dynamodb-global-tables-all-aws-regions/ (2023-09-28)

r = [
  # "il-central-1",
]
