#!/usr/bin/env bash
#
# Description: Copy certificate files from one dir to another and configure permissions.


set -e -u -o pipefail

source_dir="$1"
dest_dir="$2"

if [[ ! -d "${source_dir}" ]] ; then
  echo "ERROR: Missing source dir '${source_dir}'"
  exit 1
fi

if [[ ! -d "${dest_dir}" ]] ; then
  echo "ERROR: Missing destinatoin dir '${dest_dir}'"
  exit 1
fi

cp -v "${source_dir}"/*.{key,crt} "${dest_dir}/"
chgrp -v ssl-cert "${dest_dir}"/*.{key,crt}
chmod -v 0640 "${dest_dir}"/*.{key,crt}
