#!/bin/bash
#
# Description: A script to create a mysql backups.

# Defaults
# Override them in /etc/default/mysql_backup
BACKUP_DIR=/var/backups/mysql
MAXAGE=7 #days
METRICS_DIR=/var/lib/node_exporer

set -o pipefail

if [[ -f /etc/default/mysql_backup ]] ; then
  source /etc/default/mysql_backup
fi

# Global variables for backup status.
metric_backup_ok=0
metric_backup_started="$(date -u '+%s')"
metric_backup_completed=0
metric_backup_size=0

# Timestamp for the backup directory.
ts=$(date -u '+%Y%m%d.%H%M%S')

print_status_metrics() {
  cat << METRICS
# HELP mysql_backup_succeeded Boolean status of last backup run
# TYPE mysql_backup_succeeded gauge
mysql_backup_succeeded ${metric_backup_ok}
# HELP mysql_backup_started_seconds Start time of the last backup run
# TYPE mysql_backup_started_seconds gauge
mysql_backup_started_seconds ${metric_backup_started}
# HELP mysql_backup_completed_seconds End time of the last backup run
# TYPE mysql_backup_completed_seconds gauge
mysql_backup_completed_seconds ${metric_backup_completed}
# HELP mysql_backup_size_bytes The size of the completed backup in bytes
# TYPE mysql_backup_size_bytes gauge
mysql_backup_size_bytes ${metric_backup_size}
METRICS
}

exit_handler() {
  metric_backup_completed="$(date -u '+%s')"
  print_status_metrics | sponge "${METRICS_FILE}/mysql_backup.prom"
}

trap exit_handler EXIT

if [[ ${EUID} -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Cleanup old backups.
find "${BACKUP_DIR}" -mtime "+${MAXAGE}" -delete

output_dir="${BACKUP_DIR}/${ts}"
mkdir -p "${output_dir}"

# Jitter startup by a few seconds
sleep $((RANDOM % 30))

# Start the backup.
timeout --signal=TERM --kill-after=1h 4h \
  mydumper \
    --verbose 3 \
    --compress \
    --compress-protocol \
    --defaults-file /root/.my.cnf \
    --logfile "${LOGFILE}" \
    --host localhost \
    --threads 4 \
    --outputdir "${output_dir}" \
    --regex '^(?!(information_schema|performance_schema|sys)\.)' \
    --less-locking \
    --pmm-path="${METRICS_DIR}/" \
    --use-savepoints \
    --trx-consistency-only \
    --rows 100000

if [[ $? -ne 0 ]] ; then
  exit 1
else
  metric_backup_size="$(du -sb "${output_dir}" | awk '{print $1}')"
  metric_backup_ok=1
fi
