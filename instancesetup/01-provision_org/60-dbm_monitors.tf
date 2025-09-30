resource "datadog_monitor_json" "dbm_query_throughput_anomaly" {
  monitor = <<-EOF
{
	"id": 136574179,
	"name": "paymentdbservice: Query throughput anomaly",
	"type": "query alert",
	"query": "avg(last_12h):anomalies(sum:mysql.queries.count{host:paymentdbservice}.as_count(), 'basic', 2, direction='both', interval=120, alert_window='last_30m', count_default_zero='true') >= 0.75",
	"message": "{{#is_warning}}\n[Warning]\nOverall query throughput for database host paymentdbservice has significantly changed.\n\nValue: {{value}}\nThreshold: {{warn_threshold}}\n{{/is_warning}}\n\n{{#is_alert}}\n[Alert]\nOverall query throughput for database host paymentdbservice has significantly changed.\nValue: {{value}}\nThreshold: {{threshold}}\n{{/is_alert}}",
	"tags": [
		"team:backend",
		"dbm-suggested",
		"service:mariadb"
	],
	"options": {
		"thresholds": {
			"critical": 0.75,
			"critical_recovery": 0,
			"warning": 0.5
		},
		"notify_audit": false,
		"require_full_window": false,
		"notify_no_data": false,
		"renotify_interval": 0,
		"threshold_windows": {
			"trigger_window": "last_30m",
			"recovery_window": "last_15m"
		},
		"include_tags": false,
		"new_host_delay": 300,
		"silenced": {}
	},
	"priority": 3,
	"restricted_roles": null
}
EOF
}

resource "datadog_monitor_json" "dbm_normalise_query_anomaly" {
  monitor = <<-EOF
{
	"id": 136743878,
	"name": "paymentdbservice: Normalised Query Anomalies Detected",
	"type": "query alert",
	"query": "avg(last_4h):anomalies(avg:datadog.dbm.normalized_queries{*}, 'basic', 2, direction='both', interval=60, alert_window='last_15m', count_default_zero='true') >= 1",
	"message": "Query behaviour is unusual.\n\nPlease investigate:\nhttps://app.datadoghq.com/databases/list?dbPanels=%5B%7B%22t%22%3A%22dbHostPanel%22%2C%22h%22%3A%22paymentdbservice%22%7D%5D&start=1703128052130&end=1703131652130&paused=false",
	"tags": [],
	"options": {
		"thresholds": {
			"critical": 1,
			"critical_recovery": 0
		},
		"notify_audit": false,
		"require_full_window": false,
		"notify_no_data": false,
		"renotify_interval": 0,
		"threshold_windows": {
			"trigger_window": "last_15m",
			"recovery_window": "last_15m"
		},
		"include_tags": false,
		"new_host_delay": 300,
		"silenced": {}
	},
	"priority": null,
	"restricted_roles": null
}
EOF
}

resource "datadog_monitor_json" "dbm_agent_connectivity_lost" {
  monitor = <<-EOF
{
	"id": 136574182,
	"name": "paymentdbservice: Datadog Agent lost connectivity to database host",
	"type": "service check",
	"query": "\"mysql.can_connect\".over(\"host:paymentdbservice\").by(\"*\").last(4).count_by_status()",
	"message": "[Alert]\nUnable to connect to database host paymentdbservice",
	"tags": [
		"team:backend",
		"dbm-suggested",
		"service:mariadb"
	],
	"options": {
		"thresholds": {
			"critical": 3,
			"warning": 1,
			"ok": 3
		},
		"notify_audit": false,
		"notify_no_data": true,
		"renotify_interval": 0,
		"timeout_h": 0,
		"threshold_windows": null,
		"no_data_timeframe": 2,
		"include_tags": false,
		"new_host_delay": 300,
		"silenced": {}
	},
	"priority": 4,
	"restricted_roles": null
}
EOF
}


resource "datadog_monitor_json" "host_near_connection_limit" {
  monitor = <<-EOF
{
	"id": 136574171,
	"name": "paymentdbservice: DB Host is near the max connections limit",
	"type": "query alert",
	"query": "avg(last_5m):avg:mysql.performance.threads_connected{host:paymentdbservice} / avg:mysql.net.max_connections_available{host:paymentdbservice} > 0.95",
	"message": "Number of connections reached a ceiling.\n\n{{event.text}}",
	"tags": [
		"team:backend",
		"dbm-suggested",
		"service:mariadb"
	],
	"options": {
		"thresholds": {
			"critical": 0.95,
			"warning": 0.85
		},
		"notify_audit": false,
		"threshold_windows": null,
		"include_tags": false,
		"notify_no_data": false,
		"new_host_delay": 300,
		"silenced": {}
	},
	"priority": 3,
	"restricted_roles": null
}
EOF
}