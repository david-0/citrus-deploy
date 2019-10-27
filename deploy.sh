#!/bin/bash

if [[ "$1" == "-h" ]]; then
	echo "usage: $0 [--full]"
	echo "the script must be run in specific location to deply int or prod";
	exit 1;
fi;

level=partial

if [[ "$pwd" = "/home/alixon/usr/davidl/website/citrus-prod/citrus-deploy" ]] ; then
	systemdServiceName=citrus-prod;
fi;
if [[ "$pwd" = "/home/alixon/usr/davidl/website/citrus-int/citrus-deploy" ]] ; then
	systemdServiceName=citrus-int;
fi;
if [[ "$1" = "--full" ]]; then
	level=full;
fi;
if [[ "$systemdServiceName" = "" ]]; then
	echo "no service found";
#	exit 1;
fi;

echo "cd .."
echo "rm -rf citrus-server"
echo "git clone https://github.com/david-0/citrus-server.git"
echo "cd citrus-server"
echo "npm install"
echo "npm run build"
echo "cd .."

if [[ "$level" = "full" ]] || [[ ! -d "citrus-client" ]] ; then
	echo "rm -rf citrus-client"
	echo "git clone https://github.com/david-0/citrus-client.git"
	echo "cd citrus-client"
	echo "npm install"
else 
	echo "cd citrus-client"
	echo "git reset --hard"
	echo "git clean -fd"
fi;
echo "npm run build-prod"
echo "npm run deploy"
echo "cd .."
echo "sudo systemctl stop ${systemdServiceName}"
echo "rm -rf citrus-run"
echo "mv citrus-server citrus-run"
echo "sudo systemctl start ${systemdServiceName}"
