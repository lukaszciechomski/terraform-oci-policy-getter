terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"  # Możesz dostosować wersję według potrzeb
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Konfiguracja providera OCI
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
  
  # Używamy konfiguracji z pliku ~/.oci/config
  # Możesz też dodać poniższe parametry, jeśli nie używasz domyślnej konfiguracji
  # user_ocid        = var.user_ocid
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
}