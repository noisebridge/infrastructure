#!/bin/bash
# Generates a public MediaWiki dump (current revisions, public pages only)
# for bot/scraper consumption at dumps.noisebridge.net

set -euo pipefail

MEDIAWIKI_PATH="${MEDIAWIKI_PATH:-/srv/mediawiki/noisebridge.net}"
LOCALSETTINGS="${LOCALSETTINGS:-/srv/mediawiki/noisebridge.net/LocalSettings.php}"
PUBLIC_DIR="${PUBLIC_DIR:-/var/www/dumps.noisebridge.net}"
PUBLIC_KEEP_DAYS="${PUBLIC_KEEP_DAYS:-7}"

PHP="${PHP:-php}"
TS=$(date -u '+%Y%m%d')
OUTFILE="${PUBLIC_DIR}/noisebridge-${TS}-public.xml.gz"

echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Starting public dump -> ${OUTFILE}"
"${PHP}" "${MEDIAWIKI_PATH}/maintenance/dumpBackup.php" \
  --conf "${LOCALSETTINGS}" \
  --current --public \
  --output "gzip:${OUTFILE}.tmp"
mv "${OUTFILE}.tmp" "${OUTFILE}"
ln -sf "${OUTFILE}" "${PUBLIC_DIR}/latest.xml.gz"
echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Completed dump ($(du -sh "${OUTFILE}" | cut -f1))"

find "${PUBLIC_DIR}" -name 'noisebridge-*-public.xml.gz' -mtime "+${PUBLIC_KEEP_DAYS}" -delete

echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Done."
