// create custom log metrics for DPNCTF-17
/*
{
	"id": "frontend_requests",
	"attributes": {
		"filter": {
			"query": "service:frontend @http.req.id:*"
		},
		"group_by": [{
			"path": "@http.req.id",
			"tag_name": "http.req.id"
		}, {
			"path": "@http.req.method",
			"tag_name": "http.req.method"
		}, {
			"path": "@http.req.path",
			"tag_name": "http.req.path"
		}],
		"compute": {
			"aggregation_type": "count"
		}
	},
	"type": "logs_metrics"
}
*/
resource "datadog_logs_metric" "httpmetric" {
  name = "frontend_requests"
  compute {
    aggregation_type = "count"
  }
  filter {
    query = "service:frontend @http.req.id:*"
  }
  group_by {
    path     = "@http.req.id"
    tag_name = "http.req.id"
  }
  group_by {
    path     = "@http.req.method"
    tag_name = "http.req.method"
  }
}