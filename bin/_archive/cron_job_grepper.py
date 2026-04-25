#!/usr/bin/env python

import argparse
import re


class CronStatus(object):
    START_MATCH = "From root@Cron"
    DATE_MATCH = "Date:"
    SUBJECT_MATCH = "Subject: Cron <root@Cron>"
    END_MATCH = "Exit code:"

    @classmethod
    def parse_cronfile(cls, filename):
        """Parses the cronfile and returns list of CronStatus objects."""

        cron_stati = []
        with open(filename) as cronfile:
            in_job = False
            cron_status = None
            for line in cronfile:
                if in_body:
                    cron_status.body = cron_status.body + line

                if line.startswith(START_MATCH):
                    in_job = True
                    cron_status = CronStatus()
                elif line.startswith(SUBJECT_MATCH):
                    cron_status.subject = line.strip[len(SUBJECT_MATCH) :]
                elif line.startswith(DATE_MATCH):
                    cron_status.date = line[len(DATE_MATCH) :]
                elif in_job and not line.strip:
                    in_body = True

                if line.startswith(END_MATCH):
                    cron_stati.append(cron_status)
        return cron_stati

    def __init__(self):
        self.body = ""


parser = argparse.ArgumentParser(
    description="grep the subject lines of the various cron jobs and return the info"
)
parser.add_argument("pattern", help="the regex pattern to search for")
parser.add_argument(
    "-f",
    "--filename",
    default="/var/spool/mail/root",
    help="the qualified path of the cronfile",
)
args = parser.parse_args()

cron_stati = CronStatus.parse_cronfile(args.filename)

match_subj_re = re.compile(args.pattern)

matching_cron_stati = [
    status for status in cron_stati if match_subj_re.search(status.subject)
]

for status in matching_cron_stati:
    print(status)
