# Elastic + Kibana + Enterprise Search deployment

This repo contains a Terraform script that will deploy:

- A resource group to contain all the infrastructure
- An instance of IBM Cloud Databases for Elasticsearch Platinum
- A Code Engine Project with two applications:
    - A Kibana deployment
    - An Enterprise Search deployment

The Terraform script will ensure that all these resources can communicate with each other. It will output the public facing Kibana URL where the user can access the Enterprise Search user interface.

It will also output the URL of the Elasticsearch deployment.

## Prerequisites

- [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started)
- [An IBM Cloud Account](https://cloud.ibm.com/registration)
- [Terraform](https://www.terraform.io/)

An alternative to installing **Terraform** is to create a **Schematics** workspace on your **IBM Cloud** account to run these scripts. See [Setting up Schematics](https://cloud.ibm.com/docs/schematics?topic=schematics-sch-create-wks&interface=ui) for details.
## Steps

### Step 1

Get an API key by following [these steps](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key).

### Step 2

Clone this repo

```sh
git clone https://github.ibm.com/annumberhocker/elastic-kibana-ent-search.git
cd elastic-kibana-ent-search/terraform
```

### Step 3

Create a `terraform.tfvars` document with the following parameters:

```
ibmcloud_api_key = "<your api key>"
region = "<an ibm cloud region>" #e.g. eu-gb
es_username = "admin"
es_password = "<make up a password>" # Passwords must have between 15 and 32 characters and must contain a number, A-Z, a-z, 0-9, -, _
es_version="<a supported major version>" # eg 8.12
es_resource_group="<a new resource group to store elastic search, and code engine applications for kibana and enterprise search"
ce_project = "<a new project for Code Engine" # Will error out if project exists already
```

Note: The `variables.tf` file contains other variables you can edit to change the CPU, RAM, or disk allocation of your Elasticsearch instance.

### Step 4

Run Terraform to deploy the infrastructure:

```sh
terraform init
terraform apply --auto-approve
```

The output will contain the URL of the Kibana deployment:

```
kibana_endpoint = "https://kibana-app.1dqmr45rt678g05.eu-gb.codeengine.appdomain.cloud"
```

Log in  at this URL with the username and password you supplied above.

Once logged in, you can configure Enterprise Search by visiting `https://kibana-app.1dqmr45rt678g05.eu-gb.codeengine.appdomain.cloud/app/enterprise_search/app_search/engines`

The output also contains the URL of the Elasticsearch deployment, which can be used to connect it to WxA.

## Notes about implementation

1. There is a circular dependency in this process because Kibana needs to know the location of the Enterprise Search deployment. But Enterprise Search also needs to know where the Kibana deployment is located. Both locations are not known until they are deployed, so Terraform is unable to configure all this in one step. This is solved by the `kibana_app_update`null resource, which runs a shell script that updates the Kibana app's environment variables with the location of the Enterprise Search app after both of these have been fully deployed. 
2. The Terraform output does not contain the full version of the deployed Elastisearch instance, and this is required to deploy Kibana and Enterprise search. This is solved by the `es_metadata` data resource, which makes an API call to the deployed elasticsearch. The result of that is decoded and parsed to obtain the full version of the deployed instance. 
