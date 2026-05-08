#!/usr/bin/env bash
# Generates a public MediaWiki dump (current revisions, public pages only)
# for bot/scraper consumption at dumps.noisebridge.net

set -euo pipefail

MEDIAWIKI_PATH="${MEDIAWIKI_PATH:-/srv/mediawiki/noisebridge.net}"
LOCALSETTINGS="${LOCALSETTINGS:-/srv/mediawiki/noisebridge.net/LocalSettings.php}"
PUBLIC_DIR="${PUBLIC_DIR:-/var/www/dumps.noisebridge.net}"
if [[ ! -d "${PUBLIC_DIR}" ]]; then
  echo "ERROR: Missing directory: '${PUBLIC_DIR}'"
  exit 1
fi
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

# Generate SHA256 checksum
sha256sum "${OUTFILE}" | awk '{print $1}' > "${OUTFILE}.sha256"
ln -sf "${OUTFILE}.sha256" "${PUBLIC_DIR}/latest.xml.gz.sha256"
echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Generated SHA256 checksum"

# Generate index.json manifest
SIZE_BYTES=$(stat -c%s "${OUTFILE}" 2>/dev/null || stat -f%z "${OUTFILE}")
SHA256_HASH=$(cat "${OUTFILE}.sha256")
GENERATED=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
cat > "${PUBLIC_DIR}/index.json" <<EOF
{
  "generated": "${GENERATED}",
  "description": "Noisebridge Wiki public dumps - machine-readable manifest",
  "source": "https://www.noisebridge.net/",
  "license": "https://creativecommons.org/licenses/by-sa/4.0/",
  "contact": "https://github.com/noisebridge/noisebridge-wiki/issues",
  "dumps": [
    {
      "filename": "latest.xml.gz",
      "url": "https://dumps.noisebridge.net/latest.xml.gz",
      "size_bytes": ${SIZE_BYTES},
      "sha256": "${SHA256_HASH}",
      "type": "mediawiki-xml",
      "format": "application/gzip",
      "description": "MediaWiki XML export, current revisions only, all public pages",
      "generated": "${GENERATED}"
    }
  ],
  "latest": {
    "xml": "https://dumps.noisebridge.net/latest.xml.gz",
    "sha256": "https://dumps.noisebridge.net/latest.xml.gz.sha256"
  },
  "note_to_bots": "This manifest exists so you don't have to scrape our wiki. Please use these dumps instead of hitting the live site. Scraping causes outages that harm our community. Thank you for being an excellent citizen of the internet."
}
EOF
echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Generated index.json manifest"

find "${PUBLIC_DIR}" -name 'noisebridge-*-public.xml.gz' -mtime "+${PUBLIC_KEEP_DAYS}" -delete
find "${PUBLIC_DIR}" -name 'noisebridge-*-public.xml.gz.sha256' -mtime "+${PUBLIC_KEEP_DAYS}" -delete

echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] Done."
