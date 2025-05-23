locals {

  all_policies = concat(local.child_compartment_policies,local.root_policies)
  # Parsowanie polityk
  parsed_policies = [
      for policy in local.all_policies : {

        __compartment_name=policy.compartment
      __policy_name=policy.policy_name
        __policy_statement  = policy.statement

        # Parsowanie głównych elementów
        a_keyword = split(" ", lower(policy.statement))[0]

        # Parsowanie podmiotu (subject) - tylko dla allow/endorse
        aa_subject_type = split(" ", lower(policy.statement))[0] != "define" ? try(regex("(allow|endorse) (group|dynamic-group|any-group|any-user|service|group id|dynamic-group id)", lower(policy.statement))[1], "") : ""
        b_subject_name = split(" ", lower(policy.statement))[0] != "define" ? try(regex("(allow|endorse) (group|dynamic-group|group id|dynamic-group id|service) ([^ ]+)", lower(policy.statement))[2], "") : ""

        # Parsowanie czasownika (verb) i resource_type - obsługa obu formatów
        c_verb = split(" ", lower(policy.statement))[0] != "define" ? (
          try(regex("to ({.*})", lower(policy.statement))[0], "") == "" ?
            try(regex("to (manage|read|use|inspect)", lower(policy.statement))[0], "") : ""
        ) : ""

        d_resource_type = split(" ", lower(policy.statement))[0] != "define" ? (
          try(regex("to ({.*}) ", lower(policy.statement))[0], "") != "" ?
            upper(try(regex("to ({.*}) ", lower(policy.statement))[0], "")) :
            try(regex(" (manage|read|use|inspect) ([^ ]+) in", lower(policy.statement))[1], "")
        ) : ""

        # Parsowanie lokalizacji (location) - tylko dla allow/endorse
        e_location_type = split(" ", lower(policy.statement))[0] != "define" ? try(regex(" in (tenancy|compartment)", lower(policy.statement))[0], "") : regex(" (tenancy|compartment) ", lower(policy.statement))[0]
        f_location_name = split(" ", lower(policy.statement))[0] != "define" ? try(
          coalesce(
            try(regex(" in compartment ([^ ]+)", lower(policy.statement))[0], ""),
            try(regex(" in tenancy ([^ ]+)", lower(policy.statement))[0], "")
          ),
          ""
        ) : ""

        # Parsowanie dla define
        h_define_resource = split(" ", lower(policy.statement))[0] == "define" ? try(regex("define tenancy (.*) as", lower(policy.statement))[0], "") : ""
        i_define_alias = split(" ", lower(policy.statement))[0] == "define" ? try(regex("as (.+)", lower(policy.statement))[0], "") : ""

        # Warunek where
        g_where_clause = try(regex("where (.*)", lower(policy.statement))[0], "") != "" ? regex("where (.*)", lower(policy.statement))[0] : ""
      }
    ]

  csv_header = "compartment_name;policy_name;policy_statement;keyword;subject_type;subject_name;verb;resource_type;location_type;location_name;where_clause;define_resource;define_alias"

  csv_data =  [for policy in local.parsed_policies:
    "${policy.__compartment_name};${policy.__policy_name};${policy.__policy_statement};${policy.a_keyword};${policy.aa_subject_type};${policy.b_subject_name};${policy.c_verb};${policy.d_resource_type};${policy.e_location_type};${policy.f_location_name};${policy.g_where_clause};${policy.h_define_resource};${policy.i_define_alias}"
  ]

  csv_content = "${local.csv_header}${join("\n", local.csv_data)}"

}

resource "local_file" "policies_csv" {
  content  = local.csv_content
  filename = "${path.module}/output/policies.csv"
}


output "xxx" {
  value = local.csv_data
}