variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "Default zone for resources"
  type        = string
  default     = "asia-northeast1-a"
}

variable "app_name" {
  description = "Application name for resource naming and tagging"
  type        = string
}

variable "app_domain" {
  description = "Application domain for monitoring"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "環境は「dev」、「staging」、または「prod」である必要があります。"
  }
}

variable "resource_labels" {
  description = "Labels to apply to all monitored resources"
  type        = map(string)
  default     = {}
}

# アラート関連の設定
variable "alert_email" {
  description = "Email address for alerts"
  type        = string
}

variable "alert_slack_channel" {
  description = "Slack channel for alerts"
  type        = string
  default     = ""
}

variable "alert_slack_token" {
  description = "Slack API token for alert notifications"
  type        = string
  sensitive   = true
  default     = ""
}

variable "pagerduty_service_key" {
  description = "PagerDuty service key for critical alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ops_team" {
  description = "Operations team name"
  type        = string
  default     = "platform-team"
}

# メトリクス関連の設定
variable "error_metric_name" {
  description = "Custom error metric name"
  type        = string
  default     = "error_count"
}

variable "latency_metric_name" {
  description = "Custom latency metric name"
  type        = string
  default     = "api_latency"
}

variable "requests_metric_name" {
  description = "Custom request count metric name"
  type        = string
  default     = "request_count"
}

# アラートしきい値の設定
variable "error_rate_threshold" {
  description = "Error rate threshold for alerting (errors per minute)"
  type        = number
  default     = 5
}

variable "latency_threshold_critical" {
  description = "Critical latency threshold in milliseconds (p99)"
  type        = number
  default     = 1000
}

variable "latency_threshold_warning" {
  description = "Warning latency threshold in milliseconds (p95)"
  type        = number
  default     = 500
}

variable "availability_threshold" {
  description = "Service availability threshold percentage"
  type        = number
  default     = 99.9
}

# インフラストラクチャ設定
variable "resource_type" {
  description = "GCP resource type to monitor"
  type        = string
  default     = "gae_app"
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/health"
}

variable "uptime_check_period" {
  description = "Period between uptime checks in seconds"
  type        = number
  default     = 60
}
