[![Akamai Property Manager](https://github.com/jaescalo/akamai-pm-tf-multiple-env-workflow/actions/workflows/akamai_pm.yaml/badge.svg)](https://github.com/jaescalo/akamai-pm-tf-multiple-env-workflow/actions/workflows/akamai_pm.yaml)

# Terraform Property Manager Multiple Environments Template

The purpose of this template is to ease the process of managing multiple environment properties (e.g. dev, qa, stage, prod) in Terraform by leveraging the [Akamai Terraform Provider](https://techdocs.akamai.com/terraform/docs) in a GitHub Workflow. 

* GitHub Actions used to run the workflow that executes Terraform to update the Akamai Property.
* A Python script gets a Cloud Access Manager Key ID. This step is **optional**.
* Terraform's state file is stored remotely in Linode's Object Storage (S3 compatible).
* Terraform updates and activates a property based on the changes performed to the rule tree. 

## Prerequisites
- [Akamai API Credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials). Also familiarize with concepts related to the `.edgerc` file.
- [Make Your First API Call with Python](https://techdocs.akamai.com/developer/docs/python)
- [Akamai Terraform Provider](https://techdocs.akamai.com/terraform/docs)
- Basic Understanding of [GitHub Actions](https://docs.github.com/en/actions) and setting up [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
- [Linode Object Storage](https://www.linode.com/lp/object-storage/) bucket with Access Keys created for storing Terraform's state file.
 
## Prepare Properties for Akamai as Code
Perhaps the most important step is to prepare the target properties for management via Akamai as Code:

* The code should be based on a production property (i.e. www.example.com NOT qa.example.com)
* If desired, perform a configuration clean-up (i.e. remove duplicated rules/behaviors, parameterize behaviors/matches, etc) which can help reduce the code length.
* All advanced rules and matches need to be converted first to [Akamai Custom Behaviors](https://techdocs.akamai.com/property-mgr/reference/custom-behaviors-and-overrides) or to the Property Manager behaviors/matches if possible. If there is an advanced override section this can also be converted to a custom advanced override.
* As of May 2024, freeze the rule tree to a specific version to avoid future catalog updates that could turn the current Akamai as Code incompatible.
* Avoid code drift by changes made outside the Akamai as Code flow and develop new processes to make sure your code is fully up to date and the single source of truth

### Terraform Declarative Property Manager
In TF provider version 3.5.0 (March 30th 2023) a new way to build and maintain the rules in the property is available. The official documentation for the declarative rule resource `rule_property_rules_builder` can be found [HERE](https://techdocs.akamai.com/terraform/docs/rules-builder)

Akamai's Terraform CLI also supports exporting a property to TF using the declarative syntax (HCL). For more information check out the [official CLI repository](https://github.com/akamai/cli-terraform#property-manager-properties).
In summary here's how you would export an existing property to TF with the declarative syntax:
```
akamai terraform export-property --rules-as-hcl <property-name>
```
After running the above all the necessary terraform files will be created plus the `import.sh` file. The latter can be used to import existing resources in Akamai into Terraform's state. 

### Additional Inputs for TF
This step is optional, however it represents a common situation where information from other sources must be collected before it can be used in Terraform. The use case here is to query the Akamai Cloud Access Manager (CAM) for the Key ID via Akamai APIs in a Python script. 
The Key ID then is used as input to the TF code to populate a field in the rule tree. This step is handy in this particular case because there is no CAM subprovider yet in TF.

## Linode Object Storage for TF Remote Backend
This template uses an S3 compatible [Linode Object Storage](https://www.linode.com/lp/object-storage/) bucket to store Terraform's state file. However any other supported remote backend can be configured.

This step is essential to the template as the environment parameterization within the code will result in different TF state files based on the environment. This is good because it also provides state file isolation per environment.

## GitHub Workflow Setup
For this demo, temporary Akamai API Credentials credentials are stored as Secret Repository variables. The naming convention for the variables used is:

- AKAMAI_CREDENTIAL_CLIENT_SECRET = Akamai `client_secret` credential
- AKAMAI_CREDENTIAL_HOST = Akamai `host` credential
- AKAMAI_CREDENTIAL_ACCESS_TOKEN = Akamai `access_token` credential
- AKAMAI_CREDENTIAL_CLIENT_TOKEN = Akamai `client_token` credential

As an option you can specify the Account Switch Key if needed:

- AKAMAI_ACCOUNT_KEY = Akamai account key for the account

Additionally for the S3 compatible Linode Object Storage the following Secret Repository variables are required:

- LINODE_OBJECT_STORAGE_BUCKET = the name of the bucket
- LINODE_OBJECT_STORAGE_ACCESS_KEY = access key for the Object Storage
- LINODE_OBJECT_STORAGE_SECRET_KEY = secret key for the Object Storage

In the `.github/workflows/akamai_pm.yaml` these variables are referenced to build the Terraform configurations.
* The Akamai variables are used to perform operations on the property such as create, update and destroy during the `terraform apply` step. Observe that these are passed as `TF_VAR_*` TF environment variables that TF can recognize.
* The Linode variables are used to build the Terraform's backend configuration which then is passed to TF during the `terraform init` command.

### GitHub Actions
The following GitHub actions play a role in this workflow:
- actions/checkout@v4: setup for git operations
- py-actions/py-dependency-install@v4: setup Python script dependencies
- hashicorp/setup-terraform@v3: setup for Terraform
- actions/upload-artifact@v4: upload artifacts

## Import Existing Property
Often times you want to manage an existing resource on Akamai via Terraform. For this to be successful the initial Terraform state must be created. This can be done by executing the `import.sh` script which runs the necessary `terraform import` commands for all the resources exported by the Akamai Terraform CLI.

In the `.github/workflows/akamai_pm.yaml` you will find this step, however it is commented out, and the reason is because it was executed on the very first run just to get the Terraform state generated. After that initial run you can comment it out or just remove it from the GitHub workflow code.

## Resources
- [Template Repository](https://github.com/jaescalo/akamai-pm-tf-multiple-env-workflow)
- [Akamai API Credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials)
- [Akamai Terraform Provider](https://techdocs.akamai.com/terraform/docs)
- [Akamai CLI for Terraform](https://github.com/akamai/cli-terraform)
- [Linode Object Storage](https://www.linode.com/lp/object-storage/)
- [Akamai Developer Youtube Channel](https://www.youtube.com/c/AkamaiDeveloper)
- [Akamai Github](https://github.com/akamai)