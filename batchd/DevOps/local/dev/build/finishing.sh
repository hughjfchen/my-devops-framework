#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "batchd" "build finishing"

[[ -e /usr/local/bin/pkg-config.modified-to-run-nix-shell ]] && mv /usr/local/bin/pkg-config.modified-to-run-nix-shell /usr/local/bin/pkg-config

done_banner "batchd" "build finishing"
