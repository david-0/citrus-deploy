#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_YELLOW='\033[0;93m'
LIGHT_MAGENTA='\033[0;95m'
NC='\033[0m' # No Color

#param 1: retVal
processExitStatus() {
	if [[ $1 -eq 0 ]]; then
		echo -e " ${GREEN}ok${NC}";
	else
		echo -e " ${RED}failed${NC}"
		exit 1;
	fi;
}

exec() {
	echo -e "${LIGHT_MAGENTA}$@${NC} ${LIGHT_YELLOW}(STARTED) >>>>${NC}"
	eval $@
	retVal=$?
	echo -e -n "${LIGHT_YELLOW}<<<< (FINISHED) ${LIGHT_MAGENTA} $@${NC} >>"
	processExitStatus $retVal
}
