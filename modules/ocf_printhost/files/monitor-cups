#!/usr/bin/env python3
"""
Collects metrics from CUPS and writes them to a text file in the Prometheus
metrics format.
"""

import sys

import cups
from prometheus_client import CollectorRegistry
from prometheus_client import Gauge
from prometheus_client import write_to_textfile


def main():
    registry = CollectorRegistry()

    classes = Gauge(
        'cups_class',
        'Existence of printer on CUPS class',
        ['class', 'printer'],
        registry=registry,
    )

    queue = Gauge(
        'cups_queue_total',
        'Size of job queue',
        ['hostname', 'state'],
        registry=registry,
    )

    conn = cups.Connection()
    for cups_class, printers in conn.getClasses().items():
        for printer in printers:
            # class is a reserved keyword, so we have to pass it via dictionary
            classes.labels(**{'class': cups_class, 'printer': printer}).set(1)

    for job_id in conn.getJobs():
        try:
            job_attrs = conn.getJobAttributes(job_id)
            queue.labels(
                hostname=job_attrs['job-originating-host-name'],
                state=job_attrs['job-state'],
            ).inc()
        except cups.IPPError:
            pass

    write_to_textfile(sys.argv[1], registry)

if __name__ == '__main__':
    sys.exit(main())
