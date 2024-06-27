data "akamai_group" "group" {
  group_name  = var.group_name
  contract_id = var.contract_id
}

data "akamai_contract" "contract" {
  group_name = data.akamai_group.group.group_name
}

resource "akamai_cp_code" "cp-code" {
  product_id  = var.product_id
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_contract.contract.group_id
  name        = var.cp_code_name
}

resource "akamai_edge_hostname" "edge-hostname-edgekey-net" {
  contract_id   = data.akamai_contract.contract.id
  group_id      = data.akamai_group.group.id
  ip_behavior   = "IPV6_COMPLIANCE"
  edge_hostname = var.edge_hostname
}

resource "akamai_property" "github-workflow-tf-demo" {
  name        = var.property_name
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_group.group.id
  product_id  = var.product_id
  hostnames {
    cname_from             = var.hostname
    cname_to               = akamai_edge_hostname.edge-hostname-edgekey-net.edge_hostname
    cert_provisioning_type = "CPS_MANAGED"
  }
  rule_format = data.akamai_property_rules_builder.github-workflow-tf-demo_rule_default.rule_format
  rules       = data.akamai_property_rules_builder.github-workflow-tf-demo_rule_default.json
  version_notes = var.version_notes
  # Version notes depend on values that change on every commit. Ignoring notes as a valid change
  lifecycle {
    ignore_changes = [ 
      version_notes,
    ]
  }
}

resource "akamai_property_activation" "github-workflow-tf-demo-staging" {
  property_id                    = akamai_property.github-workflow-tf-demo.id
  contact                        = var.emails
  version                        = var.activate_latest_on_staging ? akamai_property.github-workflow-tf-demo.latest_version : akamai_property.github-workflow-tf-demo.staging_version
  network                        = "STAGING"
  note                           = var.version_notes
  auto_acknowledge_rule_warnings = true
  
  # Activation notes depend on values that change on every commit. Ignoring notes as a valid change
  lifecycle {
    ignore_changes = [
      note,
    ]
  }
}

resource "akamai_property_activation" "github-workflow-tf-demo-production" {
  property_id                    = akamai_property.github-workflow-tf-demo.id
  contact                        = var.emails
  version                        = var.activate_latest_on_production ? akamai_property.github-workflow-tf-demo.latest_version : akamai_property.github-workflow-tf-demo.production_version
  network                        = "PRODUCTION"
  note                           = var.version_notes
  auto_acknowledge_rule_warnings = true

  # Activation notes depend on values that change on every commit. Ignoring notes as valid change
  lifecycle {
    ignore_changes = [
      note,
    ]
  }
  compliance_record {
    noncompliance_reason_no_production_traffic {
      ticket_id = "123"
    }
  }
}