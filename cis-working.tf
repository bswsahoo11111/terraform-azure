terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "example" {
  name = "your-management-group"
}

# Define CIS controller policy IDs
variable "existing_policy_ids" {
  type    = list(string)
  default = ["/providers/Microsoft.Authorization/policyDefinitions/49c23d9b-02b0-0e42-4f94-e8cef1b8381b",
    "/providers/Microsoft.Authorization/policyDefinitions/5e1de0e3-42cb-4ebc-a86d-61d0c619ca48",
    "/providers/Microsoft.Authorization/policyDefinitions/a451c1ef-c6ca-483d-87ed-f49761e3ffb5",
	"/providers/Microsoft.Authorization/policyDefinitions/fe83a0eb-a853-422d-aac2-1bffd182c5d0",
	"/providers/Microsoft.Authorization/policyDefinitions/e802a67a-daf5-4436-9ea6-f6d821dd0c5d"] # Add more CIS policy IDs as needed
}

resource "azurerm_policy_set_definition" "cis" {
  name         = "mycis"
  display_name = "mycis-controller"
  description  = "demo"
  policy_type = "Custom"
  management_group_id = azurerm_management_group.example.id

  dynamic "policy_definition_reference" {
    for_each = toset(var.existing_policy_ids)
    content {
      policy_definition_id = policy_definition_reference.value
    }
  }
}


resource azurerm_management_group_policy_assignment set {
  name                 = "assignment_name"
  display_name         = "display_name"
  description          = "description"
  management_group_id  = azurerm_management_group.example.id
  policy_definition_id = azurerm_policy_set_definition.cis.id
}