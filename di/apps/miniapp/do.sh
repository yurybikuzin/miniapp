#!/usr/bin/env bash
set -e

source "$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../sh/core/do.common.sh")"

src_svelte_dir="$proj_dir"
service_name="${app}_$kind"
node_version=18.17.0

case $cmd in
    build )
        if [[ ! $NO_BUILD || ! -e "$src_svelte_dir/build/index.js" ]]; then
            pushd "$src_svelte_dir"
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

                # install required svelte adapter
                if [[ !$(grep '@sveltejs/adapter-node' package.json) ]]; then
                    npm i -D @sveltejs/adapter-node # https://kit.svelte.dev/docs/adapter-node
                fi

                # build at last
                npm run build
            popd
        fi
    ;;
    get-dependencies-for-deploy )
        echo "$src_svelte_dir/build/index.js"
    ;;
    deploy )
        # read file `.secret` and get appropriate bot TOKEN
        export $(echo $(cat ".secret" | sed 's/#.*//g'| xargs) | envsubst)
        TOKEN=$TOKEN
        if [[ $kind != "prod" ]]; then
            token_var="TOKEN_${kind^^}"
            PORT=${!token_var}
        fi
        if [[ ! $TOKEN ]]; then
            echoerr --exit-code 1 "No token is specified in .secret for $kind"
        fi

        files_to_rsync=( 
            "$src_svelte_dir/./package.json"
            "$src_svelte_dir/./package-lock.json"
            "$src_svelte_dir/./deploy_server_helper.sh"
        )
        pushd "$src_svelte_dir"
            for i in $(fd -I -t f . build); do
                files_to_rsync+=( "$src_svelte_dir/./$i" )
            done
            export $(echo $(cat ".env" | sed 's/#.*//g'| xargs) | envsubst)
        popd

        # prepare systemd.service file
        service_exists="$(ssh $host "if [[ -e /etc/systemd/system/${service_name}.service ]]; then echo 1; fi")"
        service_file_name="${service_name}.service"
        # set PREPARE_SERVICE=1 to force 
        if [[ $PREPARE_SERVICE || !"$service_exists" ]]; then
            JSON=' { "Proj": "'$proj'", "Kind": "'$kind'", "App": "'$app'", "User": "'$User'" }'
            if [[ ! $(which handlebars-cli) ]]; then
                cargo install handlebars-cli
            fi

            systemd_service_target="$di_dir/$kind/$app/~$host/./systemd.service"
            handlebars-cli "$JSON" "$di_dir/apps/$app/systemd.service" > "$systemd_service_target"
            files_to_rsync+=( "$systemd_service_target" )

            systemd_log_target="$di_dir/$kind/$app/~$host/./systemd.log.sh"
            handlebars-cli "$JSON" "$di_dir/apps/$app/systemd.log.sh" > "$systemd_log_target"
            chmod a+x "$systemd_log_target"
            files_to_rsync+=( "$systemd_log_target" )
        fi

        # prepare `include.conf` file
        line="include /home/$User/$proj/$kind/$app/include.conf;"
        main_conf="/etc/nginx/main.conf"        
        nginx_prepared="$( ssh $host 'if [[ $(grep -qF "'$line'" '$main_conf') ]]; then echo 1; else echo 0; fi')"
        if [[ $kind != "prod" ]]; then
            DOMAIN="$kind.$DOMAIN"
            DOMAIN_RE="$kind\\\\.$DOMAIN_RE"
            port_var="PORT_${kind^^}"
            PORT=${!port_var}
        fi
        # set PREPARE_NGINX="1" to force
        if [[ $PREPARE_NGINX || $nginx_prepared -eq 0 ]]; then
            include_conf_target="$di_dir/$kind/$app/~$host/./include.conf"
            JSON='{
                "DOMAIN_RE": "'$DOMAIN_RE'",
                "PORT": "'$PORT'"
            }'
            handlebars-cli "$JSON" \
                "$di_dir/apps/$app/include.conf" \
                > "$include_conf_target"

            files_to_rsync+=( "$include_conf_target" )
        fi

        # prepare `.env` file for server side
        env_target="$di_dir/$kind/$app/~$host/./.env"
        export ORIGIN="https://$DOMAIN"
        { 
            echo ORIGIN="$ORIGIN"
            echo PORT=$PORT
            echo TOKEN=$TOKEN
        } > "$env_target"
        files_to_rsync+=( "$env_target" )

        # make destination folder on server
        x $dry_run ssh "$host" "mkdir -p $proj/$kind/$app && cd $proj/$kind/$app && rm -rf build" 
        
        #rsync to destination folder all built and prepared files
        x $dry_run rsync -avz --relative "${files_to_rsync[@]}" $host:$proj/$kind/$app/ 

        #rsync to destination folder all built and prepared files
        x $dry_run ssh "$host" "$proj/$kind/$app/deploy_server_helper.sh $service_name" 

        # assure include line exists in /etc/nginx/main.conf
        if [[ $PREPARE_NGINX || $nginx_prepared -eq 0 ]]; then
            x $dry_run ssh $host "grep -qF '$line' "$main_conf" || echo '$line' | sudo tee -a $main_conf"
            x $dry_run ssh $host "sudo nginx -t && sudo nginx -s reload"
        fi

        # setWebhook
        x curl -w "\n" "https://api.telegram.org/bot${TOKEN}/setWebhook?url=${ORIGIN}/webhook"
        x sleep 10 # before check by curl
        x $dry_run curl --silent --show-error --fail "$ORIGIN" -o /dev/null
    ;;
    after-deploy )
            cat << EOM
# == DID DEPLOY
EOM
    ;;
esac

