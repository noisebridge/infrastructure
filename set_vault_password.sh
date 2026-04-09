#!/usr/bin/env bash
#
# Description: Set up the vault password from an env var.
#

if [[ -z "${ANSIBLE_VAULT_PASSWORD}" ]]; then
  echo 'ERROR: Missing ANSIBLE_VAULT_PASSWORD environment variable'
  exit 1
fi

echo "${ANSIBLE_VAULT_PASSWORD}" > .vault-password
