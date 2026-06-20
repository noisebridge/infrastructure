#!/usr/bin/env bash
#
# check_atproto_handle.sh — verify a domain's atproto / Bluesky handle is live.
#
# A handle (e.g. noisebridge.net) is verified to an account when EITHER:
#   * DNS: a TXT record at _atproto.<handle> contains  did=<did>   (preferred), or
#   * HTTP: https://<handle>/.well-known/atproto-did  returns <did> (legacy).
#
# This repo serves the handle via DNS (files/coredns/zones/noisebridge.net); the
# old m3/caddy HTTP handler was removed. This script confirms the DNS record is
# live from multiple vantage points — central public resolvers AND our own
# authoritative name servers — and reports whether the legacy HTTP path is still
# answering.
#
# Two ways to use it:
#   * Standalone / CI / post-deploy:  ./check_atproto_handle.sh
#       Prints a human-readable report. Exits 0 if the handle is verified from
#       every required DNS vantage point; otherwise exits with the number of
#       failing resolvers (capped at 125).
#   * Monitoring:  ./check_atproto_handle.sh --textfile [PATH]
#       Also writes node_exporter textfile-collector metrics (atomically) so
#       Prometheus/Grafana track it with no extra scrape config. Mirrors the
#       mydumper .prom pattern. Default PATH: /var/lib/node_exporter/atproto_handle.prom
#
# Config via environment (all optional):
#   ATPROTO_HANDLE     domain handle           (default: noisebridge.net)
#   ATPROTO_DID        expected DID            (default: did:plc:4fn5ffs6txnxxozezxio3v7o)
#   ATPROTO_RESOLVERS  space-separated label=server pairs to query over DNS
#   ATPROTO_NO_HTTP    set to 1 to skip the legacy HTTP well-known check
#
# Dependencies: dig (dnsutils/bind9-dnsutils), curl.

set -uo pipefail

HANDLE="${ATPROTO_HANDLE:-noisebridge.net}"
DID="${ATPROTO_DID:-did:plc:4fn5ffs6txnxxozezxio3v7o}"
NO_HTTP="${ATPROTO_NO_HTTP:-0}"

# label=server vantage points: central public resolvers + our authoritative NS.
# Central resolvers confirm the record is visible to the world; authoritative
# servers confirm it is published live at request time (not just cached).
DEFAULT_RESOLVERS=(
  "cloudflare=1.1.1.1"
  "google=8.8.8.8"
  "quad9=9.9.9.9"
  "ns1=ns1.noisebridge.net"
  "ns2=ns2.noisebridge.net"
)
if [[ -n "${ATPROTO_RESOLVERS:-}" ]]; then
  # shellcheck disable=SC2206
  RESOLVERS=(${ATPROTO_RESOLVERS})
else
  RESOLVERS=("${DEFAULT_RESOLVERS[@]}")
fi

TEXTFILE=""
WRITE_TEXTFILE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --textfile)
      WRITE_TEXTFILE=1
      if [[ -n "${2:-}" && "${2}" != -* ]]; then
        TEXTFILE="$2"; shift
      else
        TEXTFILE="/var/lib/node_exporter/atproto_handle.prom"
      fi
      ;;
    --no-http) NO_HTTP=1 ;;
    -h|--help)
      sed -n '2,40p' "$0"; exit 0 ;;
    *)
      echo "unknown argument: $1" >&2; exit 64 ;;
  esac
  shift
done

QNAME="_atproto.${HANDLE}"
EXPECT="did=${DID}"

# --- run the checks, collecting results -------------------------------------
declare -a LABELS=()        # vantage label (resolver label, or "http")
declare -a KINDS=()         # "dns" | "http"
declare -a OKS=()           # 1 | 0
declare -a DETAILS=()       # human detail string

dns_failures=0
dns_total=0
any_verified=0

for entry in "${RESOLVERS[@]}"; do
  label="${entry%%=*}"
  server="${entry#*=}"
  dns_total=$((dns_total + 1))
  answer="$(dig +short +time=3 +tries=1 TXT "@${server}" "${QNAME}" 2>/dev/null)"
  if printf '%s\n' "${answer}" | grep -Fq "${EXPECT}"; then
    ok=1
    detail="${server} -> match"
    any_verified=1
  else
    ok=0
    dns_failures=$((dns_failures + 1))
    if [[ -z "${answer}" ]]; then
      detail="${server} -> NO ANSWER"
    else
      detail="${server} -> mismatch: ${answer//$'\n'/ }"
    fi
  fi
  LABELS+=("${label}"); KINDS+=("dns"); OKS+=("${ok}"); DETAILS+=("${detail}")
done

http_ok=-1   # -1 = not checked
if [[ "${NO_HTTP}" != "1" ]]; then
  http_ok=0
  body="$(curl -fsS --max-time 5 "https://${HANDLE}/.well-known/atproto-did" 2>/dev/null)"
  if [[ "$(printf '%s' "${body}" | tr -d '[:space:]')" == "${DID}" ]]; then
    http_ok=1
    any_verified=1
    detail="returns DID (legacy method still active)"
  elif [[ -z "${body}" ]]; then
    detail="no /.well-known/atproto-did (expected after DNS migration)"
  else
    detail="unexpected body: ${body}"
  fi
  LABELS+=("http"); KINDS+=("http"); OKS+=("${http_ok}"); DETAILS+=("${detail}")
fi

# --- human-readable report --------------------------------------------------
echo "atproto handle verification for ${HANDLE}"
echo "  expected DID: ${DID}"
echo "  DNS record:   ${QNAME} TXT \"${EXPECT}\""
echo
echo "DNS vantage points:"
for i in "${!LABELS[@]}"; do
  [[ "${KINDS[$i]}" == "dns" ]] || continue
  if [[ "${OKS[$i]}" == "1" ]]; then mark="PASS"; else mark="FAIL"; fi
  printf '  [%s] %-12s %s\n' "${mark}" "${LABELS[$i]}" "${DETAILS[$i]}"
done
if [[ "${http_ok}" -ge 0 ]]; then
  echo
  echo "Legacy HTTP method:"
  if [[ "${http_ok}" == "1" ]]; then mark="PASS"; else mark="----"; fi
  printf '  [%s] %-12s %s\n' "${mark}" "well-known" "${DETAILS[$((${#DETAILS[@]} - 1))]}"
fi

dns_pass=$((dns_total - dns_failures))
echo
echo "Summary: ${dns_pass}/${dns_total} DNS vantage points verified; handle verified overall: $([[ "${any_verified}" == "1" ]] && echo yes || echo NO)"
if [[ "${dns_failures}" -gt 0 ]]; then
  echo "Failing DNS resolvers:"
  for i in "${!LABELS[@]}"; do
    [[ "${KINDS[$i]}" == "dns" && "${OKS[$i]}" == "0" ]] || continue
    echo "  - ${LABELS[$i]} (${DETAILS[$i]})"
  done
fi

# --- optional node_exporter textfile metrics --------------------------------
if [[ "${WRITE_TEXTFILE}" == "1" ]]; then
  now="$(date +%s)"
  {
    echo '# HELP atproto_handle_dns_verified _atproto TXT record resolves to expected DID (1) or not (0), per resolver.'
    echo '# TYPE atproto_handle_dns_verified gauge'
    for i in "${!LABELS[@]}"; do
      [[ "${KINDS[$i]}" == "dns" ]] || continue
      echo "atproto_handle_dns_verified{handle=\"${HANDLE}\",resolver=\"${LABELS[$i]}\"} ${OKS[$i]}"
    done
    if [[ "${http_ok}" -ge 0 ]]; then
      echo '# HELP atproto_handle_http_verified Legacy /.well-known/atproto-did returns expected DID (1) or not (0).'
      echo '# TYPE atproto_handle_http_verified gauge'
      echo "atproto_handle_http_verified{handle=\"${HANDLE}\"} ${http_ok}"
    fi
    echo '# HELP atproto_handle_verified Handle verified by at least one method/vantage (1) or not (0).'
    echo '# TYPE atproto_handle_verified gauge'
    echo "atproto_handle_verified{handle=\"${HANDLE}\"} ${any_verified}"
    echo '# HELP atproto_handle_dns_failures Number of DNS vantage points failing to return the expected DID.'
    echo '# TYPE atproto_handle_dns_failures gauge'
    echo "atproto_handle_dns_failures{handle=\"${HANDLE}\"} ${dns_failures}"
    echo '# HELP atproto_handle_check_timestamp_seconds Unix time of the last atproto handle check.'
    echo '# TYPE atproto_handle_check_timestamp_seconds gauge'
    echo "atproto_handle_check_timestamp_seconds{handle=\"${HANDLE}\"} ${now}"
  } > "${TEXTFILE}.$$"
  # Atomic publish: rename on the same filesystem so node_exporter never reads
  # a half-written file (same guarantee mydumper gets from `sponge`).
  mv -f "${TEXTFILE}.$$" "${TEXTFILE}"
fi

# Exit non-zero on any DNS vantage failure (capped to a valid exit code).
if [[ "${dns_failures}" -gt 125 ]]; then exit 125; fi
exit "${dns_failures}"
