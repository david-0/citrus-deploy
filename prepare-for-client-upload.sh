#!/bin/bash

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

exec cd ..
exec rm -rf prebuilt-client
