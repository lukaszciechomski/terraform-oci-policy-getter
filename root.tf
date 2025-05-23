# Pobieranie polityk dla root compartment
data "oci_identity_policies" "root_policies" {
  compartment_id = var.tenancy_ocid
  state          = "ACTIVE"
}

locals {

  # Parsowanie polityk
  root_policies = flatten([
    for policy in data.oci_identity_policies.root_policies.policies : [
      for statement in policy.statements : {
        compartment = "root"
        policy_name = policy.name
        statement   = statement
      }
    ]
  ])

}



