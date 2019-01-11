#!/bin/bash
#
# Author: Ben Kochie <superq@gmail.com>

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/X11R6/bin"

ERROR() {
  echo "ERROR: $*" 2>&1
}

git_home="$(git rev-parse --show-toplevel)"
if [[ ! -d "${git_home}" ]] ; then
  echo "ERROR: Not in the git repo"
  exit 1
fi

target="$1"
if [[ $# -ne 1 || -z "${target}" ]] ; then
  echo "usage: $(basename $0) <target host>"
  exit 1
fi

if ! host "${target}" > /dev/null ; then
  ERROR "Could not resolve target ${target}"
  exit 1
fi

target_file="${git_home}/backups/routers/${target}"

if [[ ! -f "${target_file}" ]] ; then
  echo "Adding new router target file '${target}'"
  touch "${target_file}"
  git add "${target_file}"
fi

cmd="$(cat << 'CMD'
if [ -f /bin/cli-shell-api ] ; then
  /bin/cli-shell-api showCfg
else
  echo "ERROR: Unable to find cli-shell-api"
  exit 1
fi
CMD
)"

tmpfile=$(mktemp /tmp/vyatta-bakup.XXXXXXXXXX)
lastsum=$(shasum -a 256 "${target_file}" | cut -f1 -d' ')
ssh -qax "${target}" "${cmd}" > ${tmpfile}
newsum=$(shasum -a 256 "${tmpfile}" | cut -f1 -d' ')
if [ "${lastsum}" != "${newsum}" ] ; then
  echo "Found new config"
  cp "${tmpfile}" "${target_file}"
  chmod 644 "${target_file}"
  git add "${target_file}"
  git diff --cached "${target_file}"
  echo "INFO: Backed up, don't forget to commit/push"
else
  echo "INFO: No diff in backup"
fi
rm "${tmpfile}"
