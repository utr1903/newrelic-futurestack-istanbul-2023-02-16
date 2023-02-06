##################
### Dashboards ###
##################

# Applications
resource "newrelic_one_dashboard" "apps" {
  name = "Future Stack - OSS - Application Monitoring"

  ####################
  ### WEB INSIGHTS ###
  ####################
  page {
    name = "Web Insights"

    # Page description
    widget_markdown {
      title  = "Page description"
      row    = 1
      column = 1
      height = 2
      width  = 3

      text = "## Web transactions\nRefers to synchronous calls\n- HTTP\n- gRPC"
    }

    # Average web response time (ms)
    widget_billboard {
      title  = "Average web response time (ms)"
      row    = 1
      column = 4
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT sum(http_server_duration_sum) / sum(http_server_duration_count) WHERE service_name IN ({{apps}}) FACET service_name"
      }
    }

    # Average web throughput (rpm)
    widget_billboard {
      title  = "Average web throughput (rpm)"
      row    = 1
      column = 7
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT rate(sum(http_server_requests_count), 1 minute) AS `num` WHERE service_name IN ({{apps}}) FACET service_name, k8s_pod_name LIMIT MAX) SELECT sum(`num`) FACET service_name"
      }
    }

    # Average web error rate (%)
    widget_billboard {
      title  = "Average web error rate (%)"
      row    = 1
      column = 10
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT filter(count(http_server_duration_sum), WHERE http_status_code >= 500) / count(http_server_duration_sum) * 100 as 'Average web error rate (%)' WHERE service_name IN ({{apps}}) FACET service_name"
      }
    }

    # Average web response time timeseries (ms)
    widget_line {
      title  = "Average web response time timeseries (ms)"
      row    = 3
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT sum(http_server_duration_sum) / sum(http_server_duration_count) WHERE service_name IN ({{apps}}) FACET service_name TIMESERIES"
      }
    }

    # Average web response time timeseries per instance (ms)
    widget_line {
      title  = "Average web response time timeseries per instance (ms)"
      row    = 3
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT sum(http_server_duration_sum) / sum(http_server_duration_count) WHERE service_name IN ({{apps}}) FACET service_name, k8s_pod_name TIMESERIES"
      }
    }

    # Average web throughput timeseries (rpm)
    widget_line {
      title  = "Average web throughput timeseries (rpm)"
      row    = 6
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT rate(sum(http_server_duration_count), 1 minute) AS `num` WHERE service_name IN ({{apps}}) FACET service_name, k8s_pod_name TIMESERIES LIMIT MAX) SELECT sum(`num`) FACET service_name TIMESERIES"
      }
    }

    # Average web throughput timeseries per instance (rpm)
    widget_line {
      title  = "Average web throughput timeseries per instance (rpm)"
      row    = 6
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(http_server_duration_count), 1 minute) AS `num` WHERE service_name IN ({{apps}}) FACET service_name, k8s_pod_name TIMESERIES LIMIT MAX"
      }
    }

    # Average web error rate timeseries (%)
    widget_line {
      title  = "Average web error rate timeseries (%)"
      row    = 9
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT filter(count(http_server_duration_count), WHERE numeric(http_status_code) >= 500)/count(http_server_duration_count)*100 as 'Average web error rate (%)' WHERE service_name IN ({{apps}}) FACET service_name TIMESERIES"
      }
    }

    # Average web error rate timeseries per instance (%)
    widget_line {
      title  = "Average web error rate timeseries per instance (%)"
      row    = 9
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT filter(count(http_server_duration_count), WHERE numeric(http_status_code) >= 500)/count(http_server_duration_count)*100 as 'Average web error rate (%)' WHERE service_name IN ({{apps}}) FACET service_name, k8s_pod_name TIMESERIES"
      }
    }
  }

  # Apps
  variable {
    name  = "apps"
    title = "Applications"
    type  = "enum"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = true

    dynamic "item" {
      for_each = var.app_names

      content {
        title = item.value
        value = item.value
      }
    }
  }
}
