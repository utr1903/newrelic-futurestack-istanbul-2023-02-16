#################
### Dashboard ###
#################

# Dashboard - APM
resource "newrelic_one_dashboard" "app" {
  name = "Future Stack - NR - Application Monitoring"

  ##############################
  ### WEB & NON-WEB INSIGHTS ###
  ##############################
  page {
    name = "Web & Non-Web Insights"

    # Page description
    widget_markdown {
      title  = "Page description"
      row    = 1
      column = 1
      height = 4
      width  = 3

      text = "## Overview Insights\n\n### Web transactions\nRefers to synchronous calls\n- HTTP\n- gRPC\n\n### Non-web transactions\nRefers to asynchronous calls.\n- Kafka\n- SQS\n- Service Bus"
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
        query      = "FROM (FROM Metric SELECT average(apm.service.overview.web*1000) AS `duration` WHERE appName IN ({{apps}}) FACET appName, segmentName LIMIT MAX) SELECT sum(`duration`) AS `Average web response time (ms)` FACET appName"
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
        query      = "FROM Metric SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Average web throughput (rpm)' WHERE appName IN ({{apps}}) AND transactionType = 'Web' FACET appName LIMIT MAX"
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
        query      = "FROM Metric SELECT count(apm.service.error.count)/count(apm.service.transaction.duration)*100 as 'Average web error rate (%)' WHERE appName IN ({{apps}}) AND transactionType = 'Web' FACET appName LIMIT MAX"
      }
    }

    # Average non-web response time (ms)
    widget_billboard {
      title  = "Average non-web response time (ms)"
      row    = 3
      column = 4
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT average(apm.service.overview.other*1000) AS `duration` WHERE appName IN ({{apps}}) FACET appName, segmentName LIMIT MAX) SELECT sum(`duration`) AS `Average non-web response time (ms)` FACET appName"
      }
    }

    # Average non-web throughput (rpm)
    widget_billboard {
      title  = "Average non-web throughput (rpm)"
      row    = 3
      column = 7
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Average non-web throughput (rpm)' WHERE appName IN ({{apps}}) AND transactionType = 'Other' FACET appName LIMIT MAX"
      }
    }

    # Average non-web error rate (%)
    widget_billboard {
      title  = "Average non-web error rate (%)"
      row    = 3
      column = 10
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT count(apm.service.error.count)/count(apm.service.transaction.duration)*100 as 'Average non-web error rate (%)' WHERE appName IN ({{apps}}) AND transactionType = 'Other' LIMIT MAX FACET appName"
      }
    }

    # Web response time by segment (ms)
    widget_area {
      title  = "Web response time by segment (ms)"
      row    = 5
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(apm.service.overview.web*1000) WHERE appName IN ({{apps}}) FACET appName, segmentName LIMIT MAX TIMESERIES"
      }
    }

    # Non-web response time by segment (ms)
    widget_area {
      title  = "Non-web response time by segment (ms)"
      row    = 5
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(apm.service.overview.other*1000) WHERE appName IN ({{apps}}) FACET appName, segmentName LIMIT MAX TIMESERIES"
      }
    }

    # Average web throughput (rpm)
    widget_line {
      title  = "Average web throughput (rpm)"
      row    = 8
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Average web throughput (rpm)' WHERE appName IN ({{apps}}) AND transactionType = 'Web' FACET appName LIMIT MAX TIMESERIES"
      }
    }

    # Average non-web throughput (rpm)
    widget_line {
      title  = "Average non-web throughput (rpm)"
      row    = 8
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Average non-web throughput (rpm)' WHERE appName IN ({{apps}}) AND transactionType = 'Other' FACET appName LIMIT MAX TIMESERIES"
      }
    }

    # Average web error rate (%)
    widget_line {
      title  = "Average web error rate (%)"
      row    = 11
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT count(apm.service.error.count)/count(apm.service.transaction.duration)*100 as 'Average web error rate (%)' WHERE appName IN ({{apps}}) AND transactionType = 'Web' FACET appName LIMIT MAX TIMESERIES"
      }
    }

    # Average non-web error rate (%)
    widget_line {
      title  = "Average non-web error rate (%)"
      row    = 11
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT count(apm.service.error.count)/count(apm.service.transaction.duration)*100 as 'Average non-web error rate (%)' WHERE appName IN ({{apps}}) AND transactionType = 'Other' FACET appName LIMIT MAX TIMESERIES"
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
