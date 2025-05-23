# Pobieranie informacji o root compartment
data "oci_identity_compartments" "root_compartments" {
  compartment_id = var.tenancy_ocid

  # Pobieramy tylko kompartmenty bezpośrednio w root
  access_level              = "ACCESSIBLE"
  compartment_id_in_subtree = false
}

# Pobieranie polityk dla każdego kompartmentu
data "oci_identity_policies" "compartment_policies" {
  for_each = {
    for c in data.oci_identity_compartments.root_compartments.compartments : c.id => c.name
  }

  compartment_id = each.key
  state          = "ACTIVE"
}
locals {
  child_compartment_policies = flatten([
      for compartment in data.oci_identity_compartments.root_compartments.compartments :
      [
      for policy in data.oci_identity_policies.root_policies.policies : [
        for statement in policy.statements : {
          compartment = compartment.name
          policy_name = policy.name
          statement   = statement
        }
      ]
    ]
    ])



  # # Tworzenie płaskiej listy polityk dla kompartmentów
  # flat_compartment_policies = flatten([
  #   for compartment_name, policies in local.safe_policies : [
  #     for policy in policies : [
  #       for statement in policy.statements : "${compartment_name};${policy.name};${statement}"
  #     ]
  #   ]
  # ])
}