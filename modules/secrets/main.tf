resource "random_password" "password" {
  count = var.create_secret ? 1 : 0

  length           = 20
  special          = true
  override_special = "$#@"
}

resource "google_secret_manager_secret" "secret_basic" {
  count = var.create_secret ? 1 : 0

  project   = var.project_id
  secret_id = var.secret_id

  labels = {
    label = var.label
  }

  replication {
    user_managed {
      replicas {
        location = var.replicas_location_1
      }
      replicas {
        location = var.replicas_location_2
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_version_basic" {
  count = var.create_secret ? 1 : 0

  secret      = google_secret_manager_secret.secret_basic[0].id
  secret_data = random_password.password[0].result
}
