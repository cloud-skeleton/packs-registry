variable "autoupdater_cron" {
  default = {
    cron     = "@daily"
    timezone = "UTC"
  }
  description = "Schedule for the autoupdater periodic job. `cron` accepts standard CRON expressions or nicknames (e.g., @hourly, @daily), and `timezone` is the IANA time zone (e.g., UTC, Europe/Vilnius) used to evaluate the schedule."
  type = object({
    cron     = string,
    timezone = string
  })
}

variable "id" {
    description = "Unique identifier used to distinguish multiple deployments of this pack with different variables."
    type        = string
}
