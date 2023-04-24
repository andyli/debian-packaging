#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
set -e
SOCAT_PATH_BASE=/tmp/vscr-docker-from-docker
SOCAT_LOG=${SOCAT_PATH_BASE}.log
SOCAT_PID=${SOCAT_PATH_BASE}.pid
ENABLE_NONROOT_DOCKER="true"
SOURCE_SOCKET="/var/run/docker-host.sock"
TARGET_SOCKET="/var/run/docker.sock"
USERNAME="vscode"
DOCKER_GID="$(grep -oP '^docker:x:\K[^:]+' /etc/group)"
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
log "Ensuring ${USERNAME} has access to ${SOURCE_SOCKET} via ${TARGET_SOCKET}"
# If enabled, try to update the docker group with the right GID. If the group is root, 
# fall back on using socat to forward the docker socket to another unix socket so 
# that we can set permissions on it without affecting the host.
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ] && [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ] && [ "${USERNAME}" != "root" ] && [ "${USERNAME}" != "0" ]; then
    SOCKET_GID=$(stat -c '%g' ${SOURCE_SOCKET})
    if [ "${SOCKET_GID}" != "0" ] && [ "${SOCKET_GID}" != "${DOCKER_GID}" ] && ! grep -E ".+:x:${SOCKET_GID}" /etc/group; then
        sudoIf groupmod --gid "${SOCKET_GID}" docker
    else
        # Enable proxy if not already running
        if [ ! -f "${SOCAT_PID}" ] || ! ps -p $(cat ${SOCAT_PID}) > /dev/null; then
            log "Enabling socket proxy."
            log "Proxying ${SOURCE_SOCKET} to ${TARGET_SOCKET} for vscode"
            sudoIf rm -rf ${TARGET_SOCKET}
            (sudoIf socat UNIX-LISTEN:${TARGET_SOCKET},fork,mode=660,user=${USERNAME} UNIX-CONNECT:${SOURCE_SOCKET} 2>&1 | sudoIf tee -a ${SOCAT_LOG} > /dev/null & echo "$!" | sudoIf tee ${SOCAT_PID} > /dev/null)
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