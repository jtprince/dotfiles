

# check pod logs (like liveness or readiness)

In Logs Explorer, query:

    logName="projects/owletcare-prod/logs/events"
    resource.labels.pod_name:"accounts-v1"

[Look up in the top right to select your time]
