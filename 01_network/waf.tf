// terraform で WAF を設定する方法を調べている時に
// traveloka/terraform-aws-waf-owasp-top-10-rules
// https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules
// というものを見つけた。参考になりそう。
//
///////////////////////////////////////////////////////////////////////////////
// WAF Rule (cnapp-waf-rule-sqli)
//
resource "aws_wafregional_sql_injection_match_set" "cnapp-waf-rule-sqli" {
  name = "cnapp-waf-rule-sqli-uri"

  sql_injection_match_tuple {
    text_transformation = "NONE"
    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "NONE"
    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "NONE"
    field_to_match {
      type = "BODY"
    }
  }
}
resource "aws_wafregional_rule" "cnapp-waf-rule-sqli" {
  name        = "cnapp-waf-rule-sqli"
  metric_name = "CnappWafRuleSqli"

  predicate {
    data_id = aws_wafregional_sql_injection_match_set.cnapp-waf-rule-sqli.id
    negated = false
    type    = "SqlInjectionMatch"
  }
}

///////////////////////////////////////////////////////////////////////////////
// WAF Rule (cnapp-waf-rule-xss)
//
resource "aws_wafregional_xss_match_set" "cnapp-waf-rule-xss" {
  name = "cnapp-waf-rule-xss"

  xss_match_tuple {
    text_transformation = "NONE"
    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "NONE"
    field_to_match {
      type = "QUERY_STRING"
    }
  }

  xss_match_tuple {
    text_transformation = "NONE"
    field_to_match {
      type = "BODY"
    }
  }
}
resource "aws_wafregional_rule" "cnapp-waf-rule-xss" {
  name        = "cnapp-waf-rule-xss"
  metric_name = "CnappWafRuleXss"

  predicate {
    data_id = aws_wafregional_xss_match_set.cnapp-waf-rule-xss.id
    negated = false
    type    = "XssMatch"
  }
}

///////////////////////////////////////////////////////////////////////////////
// WAF Rule (cnapp-waf-rule-header)
//
resource "aws_wafregional_byte_match_set" "cnapp-waf-rule-header" {
  name = "cnapp-waf-rule-header"

  byte_match_tuples {
    text_transformation   = "NONE"
    target_string         = "8f856a61-e356-45c9-91b3-0fb8f0ebc47a"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "HEADER"
      data = "x-cnapp-id"
    }
  }
}
resource "aws_wafregional_rule" "cnapp-waf-rule-header" {
  name        = "cnapp-waf-rule-header"
  metric_name = "CnappWafRuleHeader"

  predicate {
    data_id = aws_wafregional_byte_match_set.cnapp-waf-rule-header.id
    negated = false
    type    = "ByteMatch"
  }
}

///////////////////////////////////////////////////////////////////////////////
// WAF Rule Group
//
resource "aws_wafregional_rule_group" "cnapp-waf-rule-group" {
  name        = "cnapp-waf-rule-group"
  metric_name = "CnappWafRuleGroup"

  activated_rule {
    priority = 80
    rule_id  = aws_wafregional_rule.cnapp-waf-rule-sqli.id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 70
    rule_id  = aws_wafregional_rule.cnapp-waf-rule-xss.id
    action {
      type = "BLOCK"
    }
  }

  activated_rule {
    priority = 60
    rule_id  = aws_wafregional_rule.cnapp-waf-rule-header.id
    action {
      type = "ALLOW"
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
// WAF Web Acl
//
resource "aws_wafregional_web_acl" "cnapp-waf-webacl" {
  name        = "cnapp-waf-webacl"
  metric_name = "CnappWafWebacl"

  default_action {
    type = "ALLOW"
  }

  rule {
    priority = 1
    rule_id  = aws_wafregional_rule_group.cnapp-waf-rule-group.id
    type     = "GROUP"

    override_action {
      type = "NONE"
    }
  }
}
resource "aws_wafregional_web_acl_association" "cnapp-alb-ingress" {
  resource_arn = aws_alb.cnapp-alb-ingress.arn
  web_acl_id   = aws_wafregional_web_acl.cnapp-waf-webacl.id
}
