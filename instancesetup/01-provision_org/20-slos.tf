resource "datadog_service_level_objective" "paymentservice_reliability" {
  name        = "Paymentservice Reliability"
  type        = "metric"
  description = "We expect 99.5% of all payment transactions to be successful as these have a high impact on user satisfaction as well as company revenue."
  query {
    numerator   = "sum:trace.grpc.server.hits{service:paymentservice}.as_count() - sum:trace.grpc.server.errors{service:paymentservice}.as_count()"
    denominator = "sum:trace.grpc.server.hits{service:paymentservice}.as_count()"
  }

  thresholds {
    timeframe = "7d"
    target    = 99.5
    warning   = 99.8
  }

  thresholds {
    timeframe = "30d"
    target    = 99.5
    warning   = 99.8
  }

  timeframe         = "7d"
  target_threshold  = 99.5
  warning_threshold = 99.8

  tags = ["env:tsreenv",
                "team:backend",
                "bits:good_dog",
                "service:paymentservice",
                "priority:high",
                "fetch:always"
        ]
}

resource "datadog_monitor_json" "homepage_p95latency_monitor" {
  monitor = <<-EOF
{
	"name": "p95 Home Page latency is high",
	"type": "query alert",
	"query": "percentile(last_5m):p95:trace.http.request{service:frontend, resource_name:get_/} > 0.5",
	"message": "The p95 latency for loading the home page is {{value}}  which is higher than our {{^is_warning}} warning threshold of {{warn_threshold}} {{/is_warning}}  {{^is_alert}} alert threshold of {{threshold}} {{/is_alert}}",
	"tags": [
		"team:frontend",
		"bits:sit",
		"service:frontend"
	],
	"options": {
		"thresholds": {
			"critical": 0.5,
			"warning": 0.3
		},
		"notify_audit": false,
		"include_tags": false,
		"notify_no_data": false,
		"new_host_delay": 300,
		"silenced": {}
	},
	"priority": 2,
	"restricted_roles": null
}
EOF
}
    
resource "datadog_service_level_objective" "homepage_p95latency_slo" {
  name        = "Home Page p95 latency"
  type        = "monitor"
  description = "We expect the home page to load within 500ms 95% of the time."
  monitor_ids = [datadog_monitor_json.homepage_p95latency_monitor.id]
  

  thresholds {
    timeframe = "7d"
    target    = 95
    warning   = 97
  }

  thresholds {
    timeframe = "30d"
    target    = 95
    warning   = 97
  }

  timeframe         = "7d"
  target_threshold  = 95
  warning_threshold = 97

  tags = ["env:tsreenv",
                "team:frontend",
                "service:frontend",
                "bits:fetch",
                "priority:high"            
            ]

}


resource "datadog_monitor_json" "p95product_display_latency_monitor" {
  monitor = <<-EOF
{
	"id": 136568346,
	"name": "p95 Product Display latency",
	"type": "query alert",
	"query": "percentile(last_5m):p95:trace.http.request{service:frontend, resource_name:get_/product/_id} > 0.5",
	"message": "The p95 latency for loading products is {{value}}  which is higher than our {{^is_warning}} warning threshold of {{warn_threshold}} {{/is_warning}}  {{^is_alert}} alert threshold of {{threshold}} {{/is_alert}}",
	"tags": [
		"team:frontend",
		"bits:sit",
		"service:frontend"
	],
	"options": {
		"thresholds": {
			"critical": 0.5,
			"warning": 0.3
		},
		"notify_audit": false,
		"include_tags": false,
		"notify_no_data": false,
		"new_host_delay": 300,
		"silenced": {}
	},
	"priority": 2,
	"restricted_roles": null
}
EOF
}
  
resource "datadog_service_level_objective" "productpage_p95latency_slo" {
  name        = "Product Page p95 latency"
  type        = "monitor"
  description = "We expect the product pages to load within 500ms 95% of the time."
  monitor_ids = [datadog_monitor_json.p95product_display_latency_monitor.id]
  

  thresholds {
    timeframe = "7d"
    target    = 95
    warning   = 97
  }

  thresholds {
    timeframe = "30d"
    target    = 95
    warning   = 97
  }

  timeframe         = "7d"
  target_threshold  = 95
  warning_threshold = 97

  tags = ["env:tsreenv",
                "team:frontend",
                "service:frontend",
                "bits:fetch",
                "priority:high"            
            ]

}