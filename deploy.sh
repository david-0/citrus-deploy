#!/bin/bash

if [[ "$1" == "-h" ]]; then
	echo "usage: $0 [--full]"
	echo "the script must be run in specific location to deply int or prod";
	exit 1;
fi;

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

exec() {
	echo -n "$@ ... "
#	eval $@
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}ok${NC}";
	else
		echo -e "${RED}failed${NC}"
		exit 1;
	fi;
}

# parameter 1: systemdServiceName
updateDbSettings() {
	if [[ "$1" = "citrus-int" ]]; then
		exec sed -i 's/"database": "citrus"/"database": "citrus-int"/g' ormconfig.json
	fi;
}

level=partial

if [[ "$(pwd)" = "/home/alixon/usr/davidl/website/citrus-prod/citrus-deploy" ]] ; then
	systemdServiceName=citrus-prod;
fi;
if [[ "$(pwd)" = "/home/alixon/usr/davidl/website/citrus-int/citrus-deploy" ]] ; then
	systemdServiceName=citrus-int;
fi;
if [[ "$1" = "--full" ]]; then
	level=full;
fi;
if [[ "$systemdServiceName" = "" ]]; then
	echo "no service found";
	exit 1
fi;
cd ..
if [[ "$level" = "full" ]] || [[ ! -d "citrus-client" ]] ; then
	exec rm -rf citrus-server
	exec git clone https://github.com/david-0/citrus-server.git
	exec cd citrus-server
	updateDbSettings ${systemdServiceName}
	exec npm install
	exec npm run build
	exec cd ..

	exec rm -rf citrus-client
	exec git clone https://github.com/david-0/citrus-client.git
	exec cd citrus-client
	exec npm install
	exec npm run build-prod
	exec npm run deploy
	exec cd ..
	
	exec sudo systemctl stop ${systemdServiceName}
	exec rm -rf citrus-run
	exec mv citrus-server citrus-run
	exec sudo systemctl start ${systemdServiceName}
else 
	exec sudo systemctl stop ${systemdServiceName}
	exec cd citrus-server
	exec git reset --hard
	exec git clean -fd
	updateDbSettings ${systemdServiceName}
	exec rm -rf dist
	exec npm run build
	exec cd ..
	
	exec cd citrus-client
	exec git reset --hard
	exec git clean -fd
	exec npm run build-prod
	exec npm run deploy
	exec cd ..
fi;
