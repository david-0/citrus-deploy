#!/bin/bash

server=davidl@shop.el-refugio-denia.com.domains.alixon.ch

s=$(readlink -f $0)
cd ${s%/*}

. ./common.sh

exec ssh $server << EOF
	~/website/citrus-prod/citrus-deploy/prepare-for-client-upload.sh
EOF
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
	exec git pull
	exec npm run build-prod
	exec cd ..
fi;
exec scp -r citrus-client/dist $server:~/website/citrus-prod/prebuilt-client
exec ssh $server << EOF
	~/website/citrus-prod/citrus-deploy/deploy.sh $level --use-prebuilt-client
EOF
