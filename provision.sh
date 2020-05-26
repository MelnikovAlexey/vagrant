#!/usr/bin/env bash
set -euo pipefail

apt-get update -y
apt-get install curl apt-transport-https lsb-release -y
curl -so wazuh-agent.deb https://packages.wazuh.com/3.x/apt/pool/main/w/wazuh-agent/wazuh-agent_3.12.3-1_amd64.deb && sudo WAZUH_MANAGER='192.168.55.11' dpkg -i ./wazuh-agent.deb