ui = true

listener "tcp" {
  address     = "0.0.0.0:8080"
  tls_disable = 1
}

backend "file" {
  path = "/vault/file"
}

default_lease_ttl = "168h"

max_lease_ttl = "720h"