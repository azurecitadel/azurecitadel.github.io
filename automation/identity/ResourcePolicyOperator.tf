data "azurerm_subscription" "custom_role" {}

resource "azurerm_role_definition" "resource_policy_operator" {
  name        = "Resource Policy Operator"
  scope       = "/providers/Microsoft.Management/managementGroups/${data.azurerm_subscription.custom_role.tenant_id}"
  description = "Allows the assignment of policies. Also the creation of policy initiatives."

  permissions {
    actions = [
      "*/read",
      "Microsoft.Authorization/policyassignments/*",
      "Microsoft.Authorization/policySetDefinitions/read",
      "Microsoft.Authorization/policySetDefinitions/write",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.PolicyInsights/*",
      "Microsoft.Support/*"
    ]
  }

  assignable_scopes = [
    "/providers/Microsoft.Management/managementGroups/${data.azurerm_subscription.custom_role.tenant_id}"
  ]
}