#------------------------------------------------------------------------------
#
# PROVIDER SECTION
#
#------------------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # DO NOT INCLUDE CREDENTIALS HERE. CF. README.MD
}

#------------------------------------------------------------------------------
#
# VARIABLES SECTION
#
#------------------------------------------------------------------------------
variable "budget_monthly_amount" {
  type        = number
  default     = 20
  description = "The amount in euro for your budget"
}

variable "budget_alert_contacts" {
  type        = list(string)
  default     = ["rostskadat@gmail.com", "jmasnada@capgemeini.com"]
  description = "The destinatary of the budget alerts"
}

#------------------------------------------------------------------------------
#
# RESOURCES SECTION
#
#------------------------------------------------------------------------------
locals {
  budget_start_date = formatdate("2022-12-01'T00:00:00Z'", timestamp())
  budget_end_date   = timeadd(local.budget_start_date, "17520h") # 2 years
}

data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "consumption_budget" {
  name            = "default"
  subscription_id = data.azurerm_subscription.current.id

  amount     = var.budget_monthly_amount
  time_grain = "Monthly"

  time_period {
    start_date = local.budget_start_date
    end_date   = local.budget_end_date
  }

  notification {
    enabled        = true
    threshold      = 75.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_emails = var.budget_alert_contacts
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThanOrEqualTo"
    contact_emails = var.budget_alert_contacts
  }
}
