# Schedule for the autoupdater periodic job. `cron` accepts standard CRON expressions or nicknames (e.g., @hourly, @daily), and `timezone` is the IANA time zone (e.g., UTC, Europe/Vilnius) used to evaluate the schedule.
autoupdater_cron = {
    cron     = "@daily"
    timezone = "UTC"
}

# Unique identifier used to distinguish multiple deployments of this pack with different variables.
id = "main"