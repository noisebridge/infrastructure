#!/usr/bin/env bash
#
# verify_dns.sh — confirm a freshly-deployed DNS zone is actually being served.
#
# After a deploy that changes a zone file, this answers "did the change load and
# propagate?" without needing a zone transfer (AXFR) or any DNS-provider API:
#
#   * Zone is live:  query the SOA serial (a normal query, NOT AXFR) from each
#     authoritative server and assert it is >= the serial in the committed zone
#     file. Primary picks it up on reload; secondaries after transfer.
#   * Records served: query specific records (e.g. the _atproto TXT) from each
#     authoritative server and assert the answer contains the expected value.
#
# Authoritative checks GATE (they are fast, authoritative, uncached). Recursive
# resolvers are queried too but only INFORMATIONALLY — global caches legitimately
# lag up to the record TTL, so they warn rather than fail.
#
# It retries until everything serves or --timeout elapses, so it is safe to use
# as a hard post-deploy gate despite secondary-transfer lag.
#
# Runs anywhere with `dig` (control node / Ansible runner, or on a DNS host
# pointed at 127.0.0.1). Host-agnostic: no Ansible, no repo layout assumptions
# beyond the optional --zone-file.
#
# Usage:
#   verify_dns.sh [options]
#     --zone NAME              zone apex (default: noisebridge.net)
#     --zone-file PATH         read expected SOA serial from this file
#     --expect-serial N        expected serial directly (overrides --zone-file)
#     --authoritative "l=s..." space-separated label=server (default: ns1/ns2)
#     --recursive "l=s..."     space-separated label=server (default: cloudflare/google)
#     --record "NAME TYPE VAL" assert NAME/TYPE answer contains VAL (repeatable)
#     --timeout SECONDS        keep retrying until served (default: 120)
#     --interval SECONDS       delay between retries (default: 10)
#     --textfile [PATH]        also write node_exporter metrics (default path if omitted)
#     --summary                one-line output (for MOTD / login)
#     --quiet                  suppress the per-check report (keep summary line)
#
# Exit: 0 if every gating check passes within --timeout; otherwise 1.

set -uo pipefail

ZONE="noisebridge.net"
ZONE_FILE=""
EXPECT_SERIAL=""
TIMEOUT=120
INTERVAL=10
SUMMARY=0
QUIET=0
WRITE_TEXTFILE=0
TEXTFILE="/var/lib/node_exporter/dns_verify.prom"

AUTHORITATIVE=("ns1=ns1.noisebridge.net" "ns2=ns2.noisebridge.net")
RECURSIVE=("cloudflare=1.1.1.1" "google=8.8.8.8")
RECORDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --zone)          ZONE="$2"; shift ;;
    --zone-file)     ZONE_FILE="$2"; shift ;;
    --expect-serial) EXPECT_SERIAL="$2"; shift ;;
    --authoritative) read -r -a AUTHORITATIVE <<< "$2"; shift ;;
    --recursive)     read -r -a RECURSIVE <<< "$2"; shift ;;
    --no-recursive)  RECURSIVE=() ;;
    --record)        RECORDS+=("$2"); shift ;;
    --timeout)       TIMEOUT="$2"; shift ;;
    --interval)      INTERVAL="$2"; shift ;;
    --summary)       SUMMARY=1 ;;
    --quiet)         QUIET=1 ;;
    --textfile)
      WRITE_TEXTFILE=1
      if [[ -n "${2:-}" && "${2}" != -* ]]; then TEXTFILE="$2"; shift; fi
      ;;
    -h|--help) sed -n '2,40p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 64 ;;
  esac
  shift
done

# Default record assertion: the atproto/Bluesky handle TXT.
if [[ ${#RECORDS[@]} -eq 0 ]]; then
  RECORDS=("_atproto.${ZONE} TXT did=did:plc:4fn5ffs6txnxxozezxio3v7o")
fi

# Resolve the expected serial from the committed zone file if not given directly.
if [[ -z "${EXPECT_SERIAL}" && -n "${ZONE_FILE}" ]]; then
  if [[ ! -r "${ZONE_FILE}" ]]; then
    echo "verify_dns: cannot read zone file: ${ZONE_FILE}" >&2; exit 66
  fi
  # The SOA serial line looks like:  <spaces>2026061901 ; Serial
  EXPECT_SERIAL="$(awk '/;[ \t]*[Ss]erial/ {print $1; exit}' "${ZONE_FILE}")"
fi

log()  { [[ "${QUIET}" == "1" || "${SUMMARY}" == "1" ]] || printf '%s\n' "$*"; }

dig_soa_serial() { dig +short +time=3 +tries=1 SOA "${ZONE}" "@${1}" 2>/dev/null | awk '{print $3; exit}'; }
dig_record()     { dig +short +time=3 +tries=1 "${2}" "${1}" "@${3}" 2>/dev/null; }

# One full evaluation pass. Populates the RESULT_* arrays and returns 0 iff all
# gating (authoritative) checks pass.
declare -a R_LABEL R_KIND R_OK R_DETAIL
run_pass() {
  R_LABEL=(); R_KIND=(); R_OK=(); R_DETAIL=()
  local gating_fail=0 e label server serial ok name typ expect ans

  # --- authoritative SOA serial (gating) ---
  for e in "${AUTHORITATIVE[@]}"; do
    label="${e%%=*}"; server="${e#*=}"
    serial="$(dig_soa_serial "${server}")"
    if [[ -n "${EXPECT_SERIAL}" ]]; then
      if [[ -n "${serial}" && "${serial}" -ge "${EXPECT_SERIAL}" ]]; then
        ok=1; R_DETAIL+=("${server} serial ${serial} >= ${EXPECT_SERIAL}")
      else
        ok=0; gating_fail=1; R_DETAIL+=("${server} serial ${serial:-<none>} < expected ${EXPECT_SERIAL}")
      fi
    else
      # No expected serial to compare; just confirm the server answers SOA.
      if [[ -n "${serial}" ]]; then ok=1; R_DETAIL+=("${server} serving serial ${serial}")
      else ok=0; gating_fail=1; R_DETAIL+=("${server} no SOA answer"); fi
    fi
    R_LABEL+=("soa:${label}"); R_KIND+=("auth_serial"); R_OK+=("${ok}")
  done

  # --- record assertions on authoritative servers (gating) ---
  local rec
  for rec in "${RECORDS[@]}"; do
    read -r name typ expect <<< "${rec}"
    for e in "${AUTHORITATIVE[@]}"; do
      label="${e%%=*}"; server="${e#*=}"
      ans="$(dig_record "${name}" "${typ}" "${server}")"
      if printf '%s\n' "${ans}" | grep -Fq "${expect}"; then
        ok=1; R_DETAIL+=("${server} ${name} ${typ} -> match")
      else
        ok=0; gating_fail=1; R_DETAIL+=("${server} ${name} ${typ} -> ${ans:-<none>}")
      fi
      R_LABEL+=("rec:${name}@${label}"); R_KIND+=("auth_record"); R_OK+=("${ok}")
    done

    # --- same record on recursive resolvers (informational, not gating) ---
    for e in "${RECURSIVE[@]}"; do
      label="${e%%=*}"; server="${e#*=}"
      ans="$(dig_record "${name}" "${typ}" "${server}")"
      if printf '%s\n' "${ans}" | grep -Fq "${expect}"; then
        ok=1; R_DETAIL+=("${server} ${name} ${typ} -> match")
      else
        ok=0; R_DETAIL+=("${server} ${name} ${typ} -> not yet propagated")
      fi
      R_LABEL+=("rec:${name}@${label}"); R_KIND+=("recursive_record"); R_OK+=("${ok}")
    done
  done

  return "${gating_fail}"
}

# Retry until gating checks pass or the timeout elapses.
SECONDS=0
attempt=0
while true; do
  attempt=$((attempt + 1))
  if run_pass; then break; fi
  if (( SECONDS + INTERVAL > TIMEOUT )); then break; fi
  log "verify_dns: attempt ${attempt} incomplete after ${SECONDS}s; retrying in ${INTERVAL}s..."
  sleep "${INTERVAL}"
done
run_pass; gating_ok=$?   # final authoritative state for reporting/metrics

# --- report ---
auth_fail=0; rec_fail=0
for i in "${!R_LABEL[@]}"; do
  if [[ "${R_OK[$i]}" != "1" ]]; then
    case "${R_KIND[$i]}" in
      recursive_record) rec_fail=$((rec_fail + 1)) ;;
      *) auth_fail=$((auth_fail + 1)) ;;
    esac
  fi
done

if [[ "${SUMMARY}" == "1" ]]; then
  if [[ "${auth_fail}" -eq 0 ]]; then
    printf 'DNS %s: serving serial %s' "${ZONE}" "${EXPECT_SERIAL:-?}"
    [[ "${rec_fail}" -gt 0 ]] && printf ' (%d recursive resolver(s) still propagating)' "${rec_fail}"
    printf '\n'
  else
    printf 'DNS %s: NOT FULLY SERVED — %d authoritative check(s) failing\n' "${ZONE}" "${auth_fail}"
  fi
else
  log "DNS verification for ${ZONE} (expected serial: ${EXPECT_SERIAL:-<none>})"
  log "  elapsed: ${SECONDS}s over ${attempt} attempt(s)"
  log ""
  for i in "${!R_LABEL[@]}"; do
    if [[ "${R_OK[$i]}" == "1" ]]; then mark="PASS"
    elif [[ "${R_KIND[$i]}" == "recursive_record" ]]; then mark="warn"
    else mark="FAIL"; fi
    log "$(printf '  [%-4s] %-28s %s' "${mark}" "${R_LABEL[$i]}" "${R_DETAIL[$i]}")"
  done
  log ""
  log "Summary: authoritative failures: ${auth_fail}; recursive (informational) lagging: ${rec_fail}"
fi

# --- optional node_exporter textfile metrics ---
if [[ "${WRITE_TEXTFILE}" == "1" ]]; then
  now="$(date +%s)"
  {
    echo '# HELP dns_verify_authoritative_failures Authoritative (gating) DNS checks failing.'
    echo '# TYPE dns_verify_authoritative_failures gauge'
    echo "dns_verify_authoritative_failures{zone=\"${ZONE}\"} ${auth_fail}"
    echo '# HELP dns_verify_recursive_lagging Recursive resolvers not yet serving the records (informational).'
    echo '# TYPE dns_verify_recursive_lagging gauge'
    echo "dns_verify_recursive_lagging{zone=\"${ZONE}\"} ${rec_fail}"
    echo '# HELP dns_verify_served Zone fully served by all authoritative servers (1) or not (0).'
    echo '# TYPE dns_verify_served gauge'
    echo "dns_verify_served{zone=\"${ZONE}\"} $([[ ${auth_fail} -eq 0 ]] && echo 1 || echo 0)"
    if [[ -n "${EXPECT_SERIAL}" ]]; then
      echo '# HELP dns_verify_expected_serial Expected SOA serial from the committed zone file.'
      echo '# TYPE dns_verify_expected_serial gauge'
      echo "dns_verify_expected_serial{zone=\"${ZONE}\"} ${EXPECT_SERIAL}"
    fi
    echo '# HELP dns_verify_timestamp_seconds Unix time of the last DNS verification run.'
    echo '# TYPE dns_verify_timestamp_seconds gauge'
    echo "dns_verify_timestamp_seconds{zone=\"${ZONE}\"} ${now}"
  } > "${TEXTFILE}.$$"
  mv -f "${TEXTFILE}.$$" "${TEXTFILE}"
fi

[[ "${auth_fail}" -eq 0 ]] && exit 0 || exit 1
