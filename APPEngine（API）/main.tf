# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# モニタリングワークスペースの設定
resource "google_monitoring_workspace" "workspace" {
  name = "${var.project_id}-workspace"
}

# アップタイムチェックの設定
resource "google_monitoring_uptime_check_config" "http_check" {
  display_name = "http-uptime-check"
  timeout      = "10s"

  http_check {
    path         = "/health"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.app_domain
    }
  }
}

# アラートポリシーの設定
resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "High Error Rate Alert"
  combiner     = "OR"
  conditions {
    display_name = "error-rate-condition"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${var.error_metric_name}\" resource.type=\"gae_app\""
      duration        = "300s"
      comparison     = "COMPARISON_GT"
      threshold_value = 5
      trigger {
        count = 1
      }
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 通知チャネルの設定
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# ダッシュボードの設定
resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = templatefile("${path.module}/dashboard.json", {
    project_id = var.project_id
  })
}
