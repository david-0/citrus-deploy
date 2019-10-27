#!/bin/bash

server=davidl@88.99.118.38

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

exec ssh $server ~/website/citrus-int/citrus-deploy/prepare-for-client-upload.sh
if [[ "$1" = "--full" ]] || [[ "$2" = "--full" ]] ; then
	level="--full"
	exec rm -rf citrus-client
	exec git clone https://github.com/david-0/citrus-client.git
	exec cd citrus-client
	exec npm install
	exec npm run build-prod
	exec cd ..
else
	exec cd citrus-client
	exec git reset --hard
	exec git clean -fd
	exec npm run build-prod
	exec cd ..
fi;
exec scp -r citrus-client/dist $server:~/website/citrus-int/prebuilt-client
exec ssh $server ~/website/citrus-int/citrus-deploy/deploy.sh $level --use-preuilt-client
