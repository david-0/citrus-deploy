#!/bin/bash

if [[ "$1" == "-h" ]]; then
	echo "usage: $0 [--full] [--use-prebuilt-client]"
	echo "the script must be run in specific location to deply int or prod";
	exit 1;
fi;

s=$(readlink -f $0)
cd ${s%/*}

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

processExitStatus() {
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}ok${NC}";
	else
		echo -e "${RED}failed${NC}"
		exit 1;
	fi;
}

exec() {
	eval $@
	echo -n "$@ ... "
	processExitStatus
}

# parameter 1: systemdServiceName
updateDbSettings() {
	if [[ "$1" = "citrus-int" ]]; then
		echo -n "update ormconfig for integration ..."
		sed -i 's/"database": "citrus"/"database": "citrus-int"/g' ormconfig.json
		processExitStatus
	fi;
}

if [[ "$(pwd)" = "/home/alixon/usr/davidl/website/citrus-prod/citrus-deploy" ]] ; then
	systemdServiceName=citrus-prod;
fi;
if [[ "$(pwd)" = "/home/alixon/usr/davidl/website/citrus-int/citrus-deploy" ]] ; then
	systemdServiceName=citrus-int;
fi;
if [[ "$1" = "--full" ]] || [[ "$2" = "--full" ]] ; then
	level=full;
fi;
if [[ "$1" = "--use-prebuilt-client" ]] || [[ "$2" = "--use-prebuilt-client" ]] ; then
	usePrebuiltClient=yes;
fi;
if [[ "$systemdServiceName" = "" ]]; then
	echo "no service found";
	exit 1
fi;
export NG_CLI_ANALYTICS=false
cd ..
if [[ "$level" = "full" ]] || [[ ! -d "citrus-client" ]] ; then
	exec rm -rf citrus-server
	exec git clone https://github.com/david-0/citrus-server.git
	exec cd citrus-server
	updateDbSettings ${systemdServiceName}
	exec npm install
	exec npm run build
	exec cd ..

	if [[ "${usePrebuiltClient}" = "yes" ]]; then
		exec rm -rf citrus-server/dist/client
		exec mv prebuilt-client citrus-server/dist/client
	else
		exec rm -rf citrus-client
		exec git clone https://github.com/david-0/citrus-client.git
		exec cd citrus-client
		exec npm install
		exec npm run build-prod
		exec npm run deploy
		exec cd ..
	fi;
	
	exec sudo systemctl stop ${systemdServiceName}
	exec rm -rf citrus-run
	exec mv citrus-server citrus-run
	exec sudo systemctl start ${systemdServiceName}
else 
	exec sudo systemctl stop ${systemdServiceName}
	exec cd citrus-run
	exec git reset --hard
	exec git clean -fd
	updateDbSettings ${systemdServiceName}
	exec rm -rf dist
	exec npm run build
	exec cd ..
	
	if [[ "${usePrebuiltClient}" = "yes" ]]; then
		exec rm -rf citrus-server/dist/client
		exec mv prebuilt-client citrus-server/dist/client
	else
		exec cd citrus-client
		exec git reset --hard
		exec git clean -fd
		exec npm run build-prod
		exec npm run deploy
		exec cd ..
	fi;
	exec sudo systemctl start ${systemdServiceName}
fi;
