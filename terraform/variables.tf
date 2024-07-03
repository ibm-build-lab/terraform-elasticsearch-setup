variable "ibmcloud_api_key" {}
variable "region" {
    default = "us-south"
}
variable "es_database_name" {
    default = "elastic_db"
}

variable "es_password" {}
variable "es_version" {
    default = "8.12"
}
variable "es_ram_mb" {
    default = 4096
}
variable "es_disk_mb" {
    default = 102400
}
variable "es_cpu_count" {
    default = 3
}
variable "es_resource_group" {
    default = "elasticsearch_rg"
}
variable "es_tags" {
    default = ["env:dev"]
}
variable "ce_project" {
    default = "elasticsearch_proj"
}
