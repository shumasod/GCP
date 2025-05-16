terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  # リモート状態管理のためのバックエンド設定を検討
  # backend "gcs" {
  #   bucket = "terraform-state-bucket"
  #   prefix = "monitoring-state"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# アップタイムチェックの設定 - 詳細設定の追加
resource "google_monitoring_uptime_check_config" "http_check" {
  display_name = "${var.app_name} HTTP稼働確認"
  timeout      = "10s"
  period       = "60s"  # チェック頻度
  
  http_check {
    path           = var.health_check_path
    port           = "443"
    use_ssl        = true
    validate_ssl   = true
    request_method = "GET"
    headers = {
      "Content-Type" = "application/json"
    }
  }
  
  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.app_domain
    }
  }
  
  content_matchers {
    content = "OK"
    matcher = "CONTAINS_STRING"
  }
  
  # リソース管理のためのラベル追加
  user_labels = {
    environment = var.environment
    service     = var.app_name
  }
}

#
