#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Information output
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${RED}Holdfast Image${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}echo -e "${YELLOW}Linux Distribution: ${RED} $(. /etc/os-release ; echo $PRETTY_NAME)${NC}" $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} $(cat /etc/timezone)${NC}"
echo -e "${GREEN}Maintained by AleForge.net${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Modify the configuration variables using sed
pushd holdfastnaw-dedicated/configs/
if [ -f "$SERVER_CONFIG_PATH" ]; then
	echo "Found configuration file - replacing variables"
	sed -i "s/^server_name .*/server_name $(printf '%s\n' "$SERVER_NAME" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^maximum_players .*/maximum_players $(printf '%s\n' "$PLAYERS" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^server_welcome_message .*/server_welcome_message $(printf '%s\n' "$MOTD" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^server_region .*/server_region $(printf '%s\n' "$REGION" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^server_admin_password .*/server_admin_password $(printf '%s\n' "$ADMIN_PASS" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^#\{0,1\}server_password .*/server_password $(printf '%s\n' "$SERVER_PASS" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^server_port .*/server_port $(printf '%s\n' "$SERVER_PORT" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^steam_communications_port .*/steam_communications_port $(printf '%s\n' "$SERVER_COMM_PORT" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
	sed -i "s/^steam_query_port .*/steam_query_port $(printf '%s\n' "$SERVER_QUERY_PORT" | sed -e 's/[\/&]/\\&/g')/g" "$SERVER_CONFIG_PATH"
else
	echo "Configuration file not found: $SERVER_CONFIG_PATH"
fi
popd

# Replace Startup Variables
MODIFIED_STARTUP=$(echo $(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
START_COMMAND=$(echo -e ${MODIFIED_STARTUP})
echo -e ":/home/container$ ${START_COMMAND}"

# Run the Server
eval ${MODIFIED_STARTUP}