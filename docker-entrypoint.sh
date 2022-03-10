#!/bin/sh

config_file="/config/custom-config.yml"

echo "Setup Timezone to ${TZ}"
echo "${TZ}" > /etc/timezone
echo "Checking if UID: ${UID} matches user"
usermod -u ${UID} alpha
echo "Checking if GID: ${GID} matches user"
usermod -g ${GID} alpha
echo "Setting umask to ${UMASK}"
umask ${UMASK}

createConfig(){
    cat>"${1}"<<EOF
# Server related settings
address: 0.0.0.0
port: 8080
auth: true
tls: false
prefix: /
debug: false

# Default user settings (will be merged)
scope: /data
modify: false
rules: []

users:
  - username: admin
    password: admin
    modify: true
    scope: /data
EOF
}

echo "Checking if config file exist"

if [ ! -f "${config_file}" ]; then
    createConfig "${config_file}"
fi

echo "Starting..."

chown -R ${UID}:${GID} /data
chown -R ${UID}:${GID} /config
chown -R ${UID}:${GID} /app

su -c "/app/webdav -c ${config_file}" alpha