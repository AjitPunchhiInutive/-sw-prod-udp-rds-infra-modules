output "job" {
  description = "Dataflow Flex Template job attributes."
  value = {
    name   = google_dataflow_flex_template_job.main.name
    job_id = google_dataflow_flex_template_job.main.job_id
    state  = google_dataflow_flex_template_job.main.state
    region = google_dataflow_flex_template_job.main.region
  }
}

output "job_name" {
  description = "Full job name including the random suffix."
  value       = google_dataflow_flex_template_job.main.name
}

output "job_id" {
  description = "Unique Dataflow job ID."
  value       = google_dataflow_flex_template_job.main.job_id
}

output "job_suffix" {
  description = "Random hex suffix appended to the job name."
  value       = random_id.job_suffix.hex
}
