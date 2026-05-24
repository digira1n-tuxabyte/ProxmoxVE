#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://emby.media/ | Github: https://github.com/MediaBrowser/Emby.Releases

APP="Emby"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-ubuntu}"
var_version="${var_version:-24.04}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-1}"
var_gpu="${var_gpu:-yes}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/emby-server ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Finding the latest Emby Beta release..."
  # Query the GitHub API for the latest pre-release tag (beta)
  BETA_TAG=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases | grep -E '"tag_name":|"prerelease":' | grep -B 1 '"prerelease": true' | head -n 1 | cut -d '"' -f 4)

  if [[ -z "$BETA_TAG" ]]; then
    msg_error "Could not find a beta release."
    exit
  fi
  
  msg_ok "Found Beta version: ${BETA_TAG}"

  msg_info "Stopping Service"
  systemctl stop emby-server
  msg_ok "Stopped Service"

  msg_info "Downloading Beta Release (${BETA_TAG})..."
  # Download the specific Debian package for the beta tag
  wget -q -O /tmp/emby-beta.deb "https://github.com/MediaBrowser/Emby.Releases/releases/download/${BETA_TAG}/emby-server-deb_${BETA_TAG}_amd64.deb"
  
  msg_info "Installing Beta Release..."
  dpkg -i /tmp/emby-beta.deb
  rm /tmp/emby-beta.deb
  msg_ok "Installed Emby Beta"

  msg_info "Starting Service"
  systemctl start emby-server
  msg_ok "Started Service"
  msg_ok "Updated successfully to Beta!"
  exit
}
start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8096${CL}"
