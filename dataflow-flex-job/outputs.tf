output "jobs" {
  description = "All attributes of deployed Dataflow Flex Template jobs, keyed by job_name."
  value       = google_dataflow_flex_template_job.main
}
