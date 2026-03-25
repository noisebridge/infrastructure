#!/bin/bash
# MediaWiki dump script
# Generates two dumps:
#   - private (full, all revisions) for internal backup
#   - public (current revisions, public pages only) for bot consumption

set -euo pipefail

MEDIAWIKI_PATH="${MEDIAWIKI_PATH:-/srv/mediawiki/noisebridge.net-1.39.13}"
LOCALSETTINGS="${LOCALSETTINGS:-/srv/mediawiki/LocalSettings.php}"
PRIVATE_DIR="${PRIVATE_DIR:-/var/backups/wiki}"
PUBLIC_DIR="${PUBLIC_DIR:-/var/www/dumps.noisebridge.net}"
PRIVATE_KEEP_DAYS="${PRIVATE_KEEP_DAYS:-14}"
PUBLIC_KEEP_DAYS="${PUBLIC_KEEP_DAYS:-7}"

PHP="${PHP:-php}"
TS=$(date -u '+%Y%m%d')

run_dump() {
  local label="$1"
  local outfile="$2"
  shift 2
  local args=("$@")

  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Starting ${label} dump -> ${outfile}"
  "${PHP}" "${MEDIAWIKI_PATH}/maintenance/dumpBackup.php" \
    --conf "${LOCALSETTINGS}" \
    --output "gzip:${outfile}.tmp" \
    "${args[@]}"
  mv "${outfile}.tmp" "${outfile}"
  ln -sf "${outfile}" "$(dirname "${outfile}")/latest.xml.gz"
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Completed ${label} dump ($(du -sh "${outfile}" | cut -f1))"
}

# Private: full dump including all revisions and deleted content
run_dump "private" "${PRIVATE_DIR}/noisebridge-${TS}-full.xml.gz" \
  --full

# Public: current revision of each page, public namespaces only
run_dump "public" "${PUBLIC_DIR}/noisebridge-${TS}-public.xml.gz" \
  --current --public

# Prune old dumps
find "${PRIVATE_DIR}" -name 'noisebridge-*-full.xml.gz' -mtime "+${PRIVATE_KEEP_DAYS}" -delete
find "${PUBLIC_DIR}"  -name 'noisebridge-*-public.xml.gz' -mtime "+${PUBLIC_KEEP_DAYS}" -delete

echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Done."
