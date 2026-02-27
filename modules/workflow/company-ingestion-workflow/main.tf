resource "google_service_account" "workflow_sa" {
  account_id   = "workflow-service-account"
  display_name = "Service Account for Cloud Workflow to trigger Cloud Run Job"
  project      = var.project_id
}

# Grant permission to execute Cloud Run jobs
resource "google_project_iam_member" "runadmin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

# grant permission to view Cloud Monitoring metrics
resource "google_project_iam_member" "monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

resource "google_workflows_workflow" "job_triggering_workflow" {
  name            = "company-ingestion-workflow"
  region          = var.location
  service_account = google_service_account.workflow_sa.email
  call_log_level  = var.enable_log_debugging ? "LOG_ALL_CALLS" : "LOG_ERRORS_ONLY"

  source_contents = <<-EOF
  main:
    steps:
    - init:
        assign:
          - project_id: "${var.project_id}"
          - subscription_name: "${var.carrier_registration_subscription_name}"
    - getAcknowledgedMessagesCount:
        try:
          steps: 
            - callMonitoringApi:
                call: http.get
                args:
                  url: "https://monitoring.googleapis.com/v3/projects/${var.project_id}/timeSeries"
                  query:
                    filter: '$${"metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" AND resource.labels.subscription_id=\"" + subscription_name + "\""}'
                    interval.endTime: $${time.format(sys.now())} 
                    interval.startTime: $${time.format(sys.now() - 60)}
                    aggregation.alignmentPeriod: "60s"
                    aggregation.perSeriesAligner: "ALIGN_MAX"
                  auth:
                    type: OAuth2
                result: monitoringResult
            - extractValue:
                assign:
                  - unacked_messages: $${int(monitoringResult.body.timeSeries[0].points[0].value.int64Value)}
        retry:
          predicate: $${retryAllErrorsPredicate}
          max_retries: 3
          backoff:
            initial_interval: 5s
            max_interval: 60s
            multiplier: 2
    - checkMessagesCount:
        switch:
          - condition: $${unacked_messages > 0}
            next: sleepAndRetry
        next: triggerSyncInitJob
    - sleepAndRetry:
        call: sys.sleep
        args:
          seconds: 60
        next: getAcknowledgedMessagesCount
    - triggerSyncInitJob:
        call: googleapis.run.v1.namespaces.jobs.run
        args:
          name: "namespaces/${var.project_id}/jobs/${var.carrier_sync_init_job_name}"
          location: "${var.location}"
          body:
            overrides:
              containerOverrides:
                env:
                  - name: "CarrierDataSync__MaxCarriersToSync"
                    value: "1000"
    - triggerSyncWorkerJob:
        call: googleapis.run.v1.namespaces.jobs.run
        args:
          name: "namespaces/${var.project_id}/jobs/${var.carrier_sync_worker_job_name}"
          location: "${var.location}"
        result: syncWorkerJobResult
    - returnResult:
        return: $${syncWorkerJobResult}
  retryAllErrorsPredicate:
    params: [e]
    steps:
      - returnTrue:
          return: true
  EOF
}