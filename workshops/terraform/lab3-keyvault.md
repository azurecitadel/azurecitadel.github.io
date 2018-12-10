

This has been retained as it nmeeds testing.

## Azure Key Vault

We will also hard code a default key vault.  There are a few core services that we want to be able to assume when we are creating the more flexible Terraform files in the later labs, amd Key Vault is one of them.  It also give us an opportunity to introduce service principals, role assigments and scopes.

> Note that if you are an organisation looking to centralise your key and secret management whilst using multiple Terraform cloud providers then  Hashicorp has a cloud agnostic product named [Vault](https://www.vaultproject.io/).  Use of Vault is outside the scope of these labs.

We're going to need a service principal (sp) that has permissions to read the Azure Key Vault.  If you look at the [azurerm_key_vault](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html) page then you'll see we need to specify a tenant_id and an object_id.

The creation of service principals from Terraform is a current [enhancement request](https://github.com/terraform-providers/terraform-provider-azurerm/issues/16), so in the meantime we'll create the service principal via the CLI and use the tenant ID and object ID values in a couple of new Terraform variables.  

Note that by default, service principals are created with Contributor role assigned to the root of the subscription, which is far more generous than we want.  We'll therefore initially set it to no role assignment.  We'll then use Terraform to assign a valid role against the keyVaults resource group once that has been created.

### Create a service principal

* Create a service principal with no role assignment

```bash
az ad sp create-for-rbac --name "terraformKeyVaultReader" --skip-assignment
```

Note that the service principal (or sp) name must be unique within the tenancy for this command to succeed.  You can also specify a password using `--password`, but if not then the command will generate one for you and show it in the output.  Note in the output that the sp name is prefixed with `http://`, so if you were to delete the sp then the command would be `az ad sp delete --id "http://terraformKeyVaultReader"`.

If you run the following command it will query the new sp and give us the values we need for our variables.

```bash
az ad sp show --id "http://terraformKeyVaultReader" --output jsonc --query "{tenant_id:appOwnerTenantId, object_id:objectId}"
{
  "object_id": "6aee7885-a16d-4448-aeca-3788aafda778",
  "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

* Create the two new variables in the variables.tf file
    * **tenant_id**
    * **kvr_object_id**

We'll now use these new variables when creating the Key Vault.

### Create the keyvaults.tf

* Create a new keyVaults.tf file

```bash
resource "azurerm_resource_group" "keyvaults" {
    name        = "keyVaults"
    location    = "${var.loc}"
    tags        = "${var.tags}"
}

resource "azurerm_role_assignment" "keyVaultReader" {
  role_definition_name = "Reader"
  scope                = "${azurerm_resource_group.keyvaults.id}"
  principal_id         = "${var.kvr_object_id}"
}

resource "azurerm_key_vault" "default" {
    name                = "keyVault"
    resource_group_name = "${azurerm_resource_group.keyvaults.name}"
    location            = "${azurerm_resource_group.keyvaults.location}"
    tags                = "${azurerm_resource_group.keyvaults.tags}"

    depends_on          = [ "azurerm_role_assignment.keyVaultReader" ]

    sku {
        name = "standard"
    }

    tenant_id = "${var.tenant_id}"

    access_policy {
      tenant_id             = "${var.tenant_id}"
      object_id             = "${var.kvr_object_id}"
      key_permissions       = [ "get" ]
      secret_permissions    = [ "get" ]
    }
    enabled_for_deployment          = false # Azure Virtual Machines permitted to retrieve certs?
    enabled_for_template_deployment = false # ARM deployments allowed to pull secrets?
    enabled_for_disk_encryption     = true  # Azure Disk Encryptions permitted to grab secrets and unwrap keys ?
}
```

* Run through the terraform init, plan and apply workflow

The apply should fail on the keyvault resource as the keyVault name is already in use.  The key vault service creates a public endpoint, such as <https://{vault-name}.vault.azure.net> for the public cloud, and therefore the shortname needs to be unique.

* Create a new **rndstr** resource using the random_string provider type
    * 12 characters
    * lowercase alphanumerics
* Append the result to the key vault name
* Rerun through the terraform init, plan and apply workflow to create the key vault

There are a few new things to note here:

1. There are implicit dependencies on the keyVaults resource group from both the role assigment and key vault resources
1. There is an explicit dependency on the role assignment from the key vault, using a **depends_on** array
1. There are comments against some of the key vault booleans



Use the Azure [portal](http://portal.azure.com) to check the keyVaults resource group.  You should see the new key vault within it, but look at the Access Control (IAM) in the blade.  It should show the new service principal with the Reader role, similar to the filtered output below:

![Access Control](/workshops/terraform/images/accessControl.png)

Note that the Reader role is one of many inbuilt roles available.  You can also create custom roles via either the [CLI](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli#custom-roles) or [Terraform](https://www.terraform.io/docs/providers/azurerm/r/role_definition.html).

----------

keyvault.tf

```ruby
resource "azurerm_resource_group" "keyvaults" {
    name        = "keyVaults"
    location    = "${var.loc}"
    tags        = "${var.tags}"
}


resource "azurerm_role_assignment" "keyVaultReader" {
  role_definition_name = "Reader"
  scope                = "${azurerm_resource_group.keyvaults.id}"
  principal_id         = "${var.object_id}"
}


resource "random_string" "rndstr" {
  length  = 12
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_key_vault" "default" {
    name                = "keyVault${random_string.rndstr.result}"
    resource_group_name = "${azurerm_resource_group.keyvaults.name}"
    location            = "${azurerm_resource_group.keyvaults.location}"
    tags                = "${azurerm_resource_group.keyvaults.tags}"

    depends_on          = [ "azurerm_role_assignment.keyVaultReader" ]

    sku {
        name = "standard"
    }

    tenant_id = "${var.tenant_id}"

    access_policy {
      tenant_id             = "${var.tenant_id}"
      object_id             = "${var.object_id}"
      key_permissions       = [ "get" ]
      secret_permissions    = [ "get" ]
    }
    enabled_for_deployment          = false # Azure Virtual Machines permitted to retrieve certs?
    enabled_for_template_deployment = false # ARM deployments allowed to pull secrets?
    enabled_for_disk_encryption     = true  # Azure Disk Encryptions permitted to grab secrets and unwrap keys ?
}
```

variables.tf

```ruby
variable "loc" {
    description = "Default Azure region"
    default     =   "West Europe"
}

variable "tags" {
    default     = {
        source  = "citadel"
        env     = "training"
    }
}

variable "tenant_id" {
    # az ad sp show --id "http://terraformKeyVaultReader" --output tsv --query appOwnerTenantId
    description = "GUID for the Azure AD tenancy or directory. "
    default     = "<tenant_id>"
}

variable "object_id" {
    # az ad sp show --id "http://terraformKeyVaultReader" --output tsv --query objectId
    description = "Object ID for the terraformKeyVaultReader service principal"
    default     = "4e12ff32-c439-49aa-adaf-026ff6366576"
}
```