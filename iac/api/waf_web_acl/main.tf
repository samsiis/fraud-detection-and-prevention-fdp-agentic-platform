# Copyright (C) Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_wafv2_web_acl" "this" {
  name  = format("%s-%s", var.q.name, local.fdp_gid)
  scope = var.q.scope

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.rules
    content {
      name     = format("%s-%s", rule.value.vendor_name, rule.value.name)
      priority = rule.value.priority

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = var.q.metric_name
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = data.terraform_remote_state.agw.outputs.stage_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [data.terraform_remote_state.s3.outputs.arn]
}
