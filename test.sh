#!/bin/bash

if [[ "$1" = "--use-prebuilt-client" ]] || [[ "$2" = "--use-prebuilt-client" ]] ; then
	usePrebuiltClient=yes;
	echo "ok"
fi;
