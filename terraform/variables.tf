variable "ibmcloud_api_key" {}
variable "region" {
    default = "us-south"
}
variable "es_database_name" {
    default = "elastic_db"
}

variable "es_password" {
    description = "Password must have between 15 and 32 characters, must contain a number, can include A-Z, a-z, 0-9, -, _, but can not start with special characters."
}
variable "es_version" {
    default = "8.12"
}

# NOTE: es_host_flavor has replaces es_cpu_count and es_ram_mb
variable "es_host_flavor" {
    default = "b3c.4x16.encrypted"
    description = "Choose from: b3c.4x16.encrypted, b3c.8x32.encrypted, m3c.8x64.encrypted, b3c.16x64.encrypted, b3c.32x128.encrypted, m3c.30x240.encrypted"
}

#variable "es_ram_mb" {
#    default = 4096
#}

#variable "es_cpu_count" {
#    default = 3
#}

variable "es_disk_mb" {
    default = 102400
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
