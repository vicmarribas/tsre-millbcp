# Create log exclusion filter for DPNCTF-8 (Find an easter egg keyword from log messages (which are not indexed))

resource "null_resource" "log_exclusion_rules" {
    provisioner "local-exec" {
      command = <<EOT
curl -X PUT "https://api.datadoghq.com/api/v1/logs/config/indexes/main" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "DD-API-KEY: ${var.dd_api_key}" \
-H "DD-APPLICATION-KEY: ${var.dd_app_key}" \
-d @- << EOF
{
    "filter": {
        "query": ""
    },
    "num_retention_days": 15,
    "daily_limit": null,
    "exclusion_filters": [
        {
            "name": "no attackbox - not part of the game",
            "is_enabled": true,
            "filter": {
                "query": "service:attackbox",
                "sample_rate": 1
            }
        },
        {
            "name": "nothing to see here :)",
            "is_enabled": true,
            "filter": {
                "query": "service:adservice status:warn",
                "sample_rate": 1
            }
        }
    ]
}
EOF
EOT
    }

// we generate one log message to make sure that all log mgmt ui is enabled / no splash screen
provisioner "local-exec" {
      command = <<EOT
curl -X POST "https://http-intake.logs.datadoghq.com/api/v2/logs" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "DD-API-KEY: ${var.dd_api_key}" \
-H "DD-APPLICATION-KEY: ${var.dd_app_key}" \
-d "Welcome to Datadog!"
EOT
    }

}
