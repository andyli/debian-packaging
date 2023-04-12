#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

SOCAT_PATH_BASE=/tmp/vscr-docker-from-docker
SOCAT_LOG=${SOCAT_PATH_BASE}.log
SOCAT_PID=${SOCAT_PATH_BASE}.pid

# Wrapper function to only use sudo if not already root
sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# Log messages
log()
{
    echo -e "[$(date)] $@" | sudoIf tee -a ${SOCAT_LOG} > /dev/null
}

echo -e "\n** $(date) **" | sudoIf tee -a ${SOCAT_LOG} > /dev/null
log "Ensuring vscode has access to /var/run/docker-host.sock via /var/run/docker.sock"

# If enabled, try to add a docker group with the right GID. If the group is root, 
# fall back on using socat to forward the docker socket to another unix socket so 
# that we can set permissions on it without affecting the host.
if [ "true" = "true" ] && [ "/var/run/docker-host.sock" != "/var/run/docker.sock" ] && [ "vscode" != "root" ] && [ "vscode" != "0" ]; then
    SOCKET_GID=$(stat -c '%g' /var/run/docker-host.sock)
    if [ "${SOCKET_GID}" != "0" ]; then
        log "Adding user to group with GID ${SOCKET_GID}."
        if [ "$(cat /etc/group | grep :${SOCKET_GID}:)" = "" ]; then
            sudoIf groupadd --gid ${SOCKET_GID} docker-host
        fi
        # Add user to group if not already in it
        if [ "$(id vscode | grep -E "groups.*(=|,)${SOCKET_GID}\(")" = "" ]; then
            sudoIf usermod -aG ${SOCKET_GID} vscode
        fi
    else
        # Enable proxy if not already running
        if [ ! -f "${SOCAT_PID}" ] || ! ps -p $(cat ${SOCAT_PID}) > /dev/null; then
            log "Enabling socket proxy."
            log "Proxying /var/run/docker-host.sock to /var/run/docker.sock for vscode"
            sudoIf rm -rf /var/run/docker.sock
            (sudoIf socat UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=vscode UNIX-CONNECT:/var/run/docker-host.sock 2>&1 | sudoIf tee -a ${SOCAT_LOG} > /dev/null & echo "$!" | sudoIf tee ${SOCAT_PID} > /dev/null)
        else
            log "Socket proxy already running."
        fi
    fi
    log "Success"
fi

# Execute whatever commands were passed in (if any). This allows us 
# to set this script to ENTRYPOINT while still executing the default CMD.
set +e
exec "$@"
