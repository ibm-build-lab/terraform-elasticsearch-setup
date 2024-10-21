resource "ibm_database" "elastic" {
  name          = var.es_database_name
  service       = "databases-for-elasticsearch"
  plan          = "platinum"
  version       = var.es_version
  location      = var.region
  adminpassword = var.es_password
  resource_group_id = ibm_resource_group.ess_resource_group.id
  tags          = var.es_tags


  group {
    group_id = "member"

    host_flavor {
      id = var.es_host_flavor
    }

    disk {
      allocation_mb = var.es_disk_mb
    }
  }
}

data "ibm_database_connection" "es_connection" {
  endpoint_type = "public"
  deployment_id = ibm_database.elastic.id
  user_id       = "admin"
  user_type     = "database"
}

# The data object below calls the ES URL in order to establish the full version of the deployed database
# because that is needed to deploy Kibana and Ent Search
# The full version gets stored in a local variable es-ful-version and then used in the codengine resources
data "http" "es_metadata" {
  url=  "https://admin:${ibm_database.elastic.adminpassword}@${data.ibm_database_connection.es_connection.https[0].hosts[0].hostname}:${data.ibm_database_connection.es_connection.https[0].hosts[0].port}"
 insecure = true
}

locals {
    # get data from api call
    es_data = jsondecode(data.http.es_metadata.response_body)

    # get version
    es-full-version = local.es_data.version.number
}


output "es_url" {
  value     = "https://admin:${ibm_database.elastic.adminpassword}@${data.ibm_database_connection.es_connection.https[0].hosts[0].hostname}:${data.ibm_database_connection.es_connection.https[0].hosts[0].port}"
  sensitive = true
}
