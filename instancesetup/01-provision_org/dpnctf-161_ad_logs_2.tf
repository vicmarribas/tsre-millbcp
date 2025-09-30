resource "datadog_dashboard_json" "dashboard_adtech" {
  dashboard = <<-EOF
{
    "title": "Ad Analytics",
    "description": "",
    "widgets": [
        {
            "id": 202139657810900,
            "definition": {
                "title": "",
                "background_color": "vivid_purple",
                "show_title": true,
                "type": "group",
                "layout_type": "ordered",
                "widgets": [
                    {
                        "id": 5738947015036784,
                        "definition": {
                            "title": "Advertiser on",
                            "title_size": "16",
                            "title_align": "left",
                            "show_legend": false,
                            "legend_layout": "auto",
                            "legend_columns": [
                                "avg",
                                "min",
                                "max",
                                "value",
                                "sum"
                            ],
                            "time": {},
                            "type": "timeseries",
                            "requests": [
                                {
                                    "formulas": [
                                        {
                                            "formula": "clamp_max(default_zero(a), 1)"
                                        }
                                    ],
                                    "queries": [
                                        {
                                            "data_source": "logs",
                                            "name": "a",
                                            "compute": {
                                                "aggregation": "count"
                                            },
                                            "group_by": [
                                                {
                                                    "facet": "advertiser",
                                                    "limit": 10,
                                                    "sort": {
                                                        "order": "desc",
                                                        "aggregation": "count"
                                                    }
                                                }
                                            ],
                                            "search": {
                                                "query": "service:adservice state:on $advertiser"
                                            },
                                            "storage": "hot"
                                        }
                                    ],
                                    "response_format": "timeseries",
                                    "style": {
                                        "palette": "dog_classic"
                                    },
                                    "display_type": "bars"
                                }
                            ]
                        },
                        "layout": {
                            "x": 0,
                            "y": 0,
                            "width": 4,
                            "height": 2
                        }
                    },
                    {
                        "id": 3369962789378985,
                        "definition": {
                            "time": {},
                            "title": "Advertiser volume from logs",
                            "type": "treemap",
                            "requests": [
                                {
                                    "response_format": "scalar",
                                    "queries": [
                                        {
                                            "data_source": "logs",
                                            "name": "a",
                                            "compute": {
                                                "aggregation": "count"
                                            },
                                            "group_by": [
                                                {
                                                    "facet": "advertiser",
                                                    "limit": 10,
                                                    "sort": {
                                                        "order": "desc",
                                                        "aggregation": "count"
                                                    },
                                                    "should_exclude_missing": true
                                                }
                                            ],
                                            "search": {
                                                "query": "service:adservice state:seen"
                                            },
                                            "storage": "hot"
                                        }
                                    ],
                                    "formulas": [
                                        {
                                            "formula": "a"
                                        }
                                    ],
                                    "sort": {
                                        "count": 10,
                                        "order_by": [
                                            {
                                                "type": "formula",
                                                "order": "desc"
                                            }
                                        ]
                                    }
                                }
                            ]
                        },
                        "layout": {
                            "x": 4,
                            "y": 0,
                            "width": 5,
                            "height": 4
                        }
                    },
                    {
                        "id": 5502578116905296,
                        "definition": {
                            "title": "Advertiser off",
                            "title_size": "16",
                            "title_align": "left",
                            "show_legend": false,
                            "legend_layout": "auto",
                            "legend_columns": [
                                "avg",
                                "min",
                                "max",
                                "value",
                                "sum"
                            ],
                            "time": {},
                            "type": "timeseries",
                            "requests": [
                                {
                                    "formulas": [
                                        {
                                            "formula": "clamp_max(default_zero(a), 1)"
                                        }
                                    ],
                                    "queries": [
                                        {
                                            "data_source": "logs",
                                            "name": "a",
                                            "compute": {
                                                "aggregation": "count"
                                            },
                                            "group_by": [
                                                {
                                                    "facet": "advertiser",
                                                    "limit": 10,
                                                    "sort": {
                                                        "order": "desc",
                                                        "aggregation": "count"
                                                    }
                                                }
                                            ],
                                            "search": {
                                                "query": "service:adservice state:off $advertiser"
                                            },
                                            "storage": "hot"
                                        }
                                    ],
                                    "response_format": "timeseries",
                                    "style": {
                                        "palette": "dog_classic"
                                    },
                                    "display_type": "bars"
                                }
                            ]
                        },
                        "layout": {
                            "x": 0,
                            "y": 2,
                            "width": 4,
                            "height": 2
                        }
                    },
                    {
                        "id": 941694698932053,
                        "definition": {
                            "title": "Ad Impressions based on logs",
                            "title_size": "16",
                            "title_align": "left",
                            "show_legend": true,
                            "legend_layout": "vertical",
                            "legend_columns": [
                                "avg",
                                "min",
                                "max",
                                "value",
                                "sum"
                            ],
                            "time": {},
                            "type": "timeseries",
                            "requests": [
                                {
                                    "formulas": [
                                        {
                                            "formula": "cumsum(a)"
                                        }
                                    ],
                                    "queries": [
                                        {
                                            "data_source": "logs",
                                            "name": "a",
                                            "compute": {
                                                "aggregation": "count"
                                            },
                                            "group_by": [
                                                {
                                                    "facet": "advertiser",
                                                    "limit": 10,
                                                    "sort": {
                                                        "order": "desc",
                                                        "aggregation": "count"
                                                    },
                                                    "should_exclude_missing": true
                                                }
                                            ],
                                            "search": {
                                                "query": "service:adservice state:seen $advertiser"
                                            },
                                            "storage": "hot"
                                        }
                                    ],
                                    "response_format": "timeseries",
                                    "style": {
                                        "palette": "dog_classic"
                                    },
                                    "display_type": "line"
                                }
                            ]
                        },
                        "layout": {
                            "x": 0,
                            "y": 4,
                            "width": 4,
                            "height": 5
                        }
                    }
                ]
            },
            "layout": {
                "x": 0,
                "y": 0,
                "width": 9,
                "height": 12
            }
        }
    ],
    "template_variables": [
        {
            "name": "advertiser",
            "prefix": "advertiser",
            "available_values": [],
            "default": "*"
        }
    ],
    "layout_type": "ordered",
    "notify_list": [],
    "reflow_type": "fixed"
}
EOF
}