# Elastic + Kibana + Enterprise Search deployment

This repo contains Terraform scripts that will deploy:

- A resource group to contain all the infrastructure
- An instance of **IBM Cloud Databases for Elasticsearch** Platinum
- A **Code Engine** project with two applications:
    - A **Kibana** deployment
    - An **Enterprise Search** deployment

The Terraform script will ensure that all these resources can communicate with each other. It will output the public Kibana URL where the user can access the Enterprise Search user interface.

It will also output the URL of the Elasticsearch deployment.

## Prerequisites

- [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started)
- [An IBM Cloud Account](https://cloud.ibm.com/registration)
- [Terraform](https://www.terraform.io/)

An alternative to installing **Terraform** is to create a **Schematics** workspace on your **IBM Cloud** account to run these scripts. See [Setting up Schematics](https://cloud.ibm.com/docs/schematics?topic=schematics-sch-create-wks&interface=ui) for details.
## Run scripts
Get an API key by following [these steps](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key).


### Using a Schematics workspace on IBM Cloud

#### Step 1 

In `cloud.ibm.com`, search on **Schematics**.  Click on **Create a workspace**

#### Step 2 

Set the following:
- **GitHub, GitLab or Bitbucket repository URL**: `https://github.com/ibm-build-lab/elasticsearch-kibana-enterprise-search-setup`
- **Branch**: `main`
- **Folder**: `terraform` 

Click **Create**
#### Step 3

Edit the values for desired environment variables. To edit a variable, select the 3 dot menu at the end of the variable. Select **Edit**, uncheck **Use default**, enter new value and save
#### Step 4
Run `Generate Plan` to make sure there aren't any errors

Run `Apply Plan`

### Using local Terraform 

#### Step 1

Clone this repo

```sh
git clone https://github.ibm.com/ibm-build-lab/terraform-elasticsearch-setup.git
cd terraform-elasticsearch-setup/terraform
```

#### Step 2

Create a `terraform.tfvars` document with the following parameters:

```
# Required
ibmcloud_api_key = "<your api key>"
es_password = "<make up a password>" # Passwords must have between 15 and 32 characters and must contain a number, A-Z, a-z, 0-9, -, _

# Optional
region = "<an ibm cloud region>" # default is us-south
es_database_name = "<name of elasticsearch database>" # default is elastic_db
es_version="<a supported major version>" # default is 8.12
es_resource_group="<a new resource group to store database and code engine project>" # default is elasticsearch_rg
es_tags = ["<tags>"] # Default is env:dev
ce_project = "<a new project for Code Engine" # Will error out if project exists already. Default is elasticsearch_proj
es_ram_mb = <MB of RAM>  # default is 4096, must be in increments of 128
es_disk_mb = <MB of disk space> # Default is 102400, must be in increments of 128
es_cpu_count = <# of cpus> # default is 3
```

#### Step 3

Run the scripts
```sh
terraform init
terraform plan
terraform apply --auto-approve
```

### Output

The output from the Terraform scripts (in Schematics, it will be at the end of the log from the **Plan Apply** job) will contain the URL of the Kibana deployment:

```
kibana_endpoint = "https://kibana-app.************.us-south.codeengine.appdomain.cloud"
```

Log in at this URL with the username `admin` and password you created above.

Once logged in, you can configure Enterprise Search by visiting `https://<kibana_endpoint>/app/enterprise_search/app_search/engines`

The output should also provide the URL of the **Elasticsearch** deployment, which can be used to connect it to **watsonx Assistant**. If this isn't provided, you can get this by going into the database resource (cloud.ibm.com -> **Resource List** -> **Databases**), going to the **Overview** page, opening the **HTTPS** tab. **Watsonx Assistant** will expect this in the form of `https://<hostname>:<port>`

## Notes about implementation

1. There is a circular dependency in this process because Kibana needs to know the location of the Enterprise Search deployment. But Enterprise Search also needs to know where the Kibana deployment is located. Both locations are not known until they are deployed, so Terraform is unable to configure all this in one step. This is solved by the `kibana_app_update`null resource, which runs a shell script that updates the Kibana app's environment variables with the location of the Enterprise Search app after both of these have been fully deployed. 
2. The Terraform output does not contain the full version of the deployed Elastisearch instance, and this is required to deploy Kibana and Enterprise search. This is solved by the `es_metadata` data resource, which makes an API call to the deployed elasticsearch. The result of that is decoded and parsed to obtain the full version of the deployed instance. 
