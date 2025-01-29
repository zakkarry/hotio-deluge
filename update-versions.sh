#!/bin/bash
version=$(curl -fsSL "https://pypi.python.org/pypi/deluge/json" | jq -re .info.version) || exit 1
[[ -z ${version} ]] && exit 0
[[ ${version} == null ]] && exit 0
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    '.version = $version' <<< "${json}" | tee VERSION.json
