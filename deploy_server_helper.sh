#!/usr/bin/env bash

node_version=18.17.0
nvm_install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"

set -e

# USER_TO_RUN_BEHALF_OF="z9v"
# # assure we are running behalf on user'ubuntu'
# if [[ $(whoami) != "$USER_TO_RUN_BEHALF_OF" ]]; then
#     sudo -H -u "$USER_TO_RUN_BEHALF_OF" "$0"
#     exit 0
# fi

# change dir to where this script is placed
dir=$(dirname "$0")
cd "$dir"

# prepare nvm
nvm_sh="$HOME/.nvm/nvm.sh"
if [[ ! -e "$nvm_sh" ]]; then
    curl -o- "$nvm_install_url" | bash
fi
use_nvm=(source "$nvm_sh")
"${use_nvm[@]}"

# check if required version of node exists, install otherwise
set +e
version_exits="$(nvm  ls --no-colors | grep "v$node_version")"
set -e
if [[ ! $version_exits ]]; then
    nvm install $node_version
fi

# check if required version of node is used, use otherwise
set +e
version_used="$(nvm  ls --no-colors | grep "^\->     v$node_version *")"
set -e
if [[ ! $version_used ]]; then
    nvm use $node_version
fi

service_name="$1"
if [[ "$service_name" ]]; then # case'deploy'
    # install dependencies
    npm ci --omit dev

    # restart service
    service_name_file_path="/etc/systemd/system/${service_name}.service"
    if [[ ! -e "$service_name_file_path" ]]; then
        chmod a+x systemd.log.sh
        sudo cp systemd.service "$service_name_file_path"
        sudo systemctl daemon-reload 
        sudo systemctl enable $service_name
    fi
    sudo systemctl restart $service_name
else # case'systemd.service'
    node -r dotenv/config build
fi

