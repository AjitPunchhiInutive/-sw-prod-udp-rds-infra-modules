output "jobs" {
  description = "Map of deployed Dataflow Flex Template job attributes keyed by Terraform resource key."
  value = {
    for k, v in google_dataflow_flex_template_job.main : k => {
      name   = v.name
      job_id = v.job_id
      state  = v.state
      region = v.region
    }
  }
}
