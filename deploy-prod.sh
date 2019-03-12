#!/bin/bash

server=davidl@88.99.118.38

s=$(readlink -f $0)
cd ${s%/*}

echo "++++ build client" && \
	cd ../citrus-client && \
	npm run build-prod && \
	scp -r dist $server:~/website/citrus-client/dist && \\
	ssh $server << EOF 
	cd ~/website/citrus/citrus-client && \
	git pull && \\
	npm run deploy
EOF
[ $? -eq 0 ] && \
	echo "++++ build server" && \
	ssh $server << EOF 
	npm run reload
EOF
[ $? -eq 0 ] && \
	echo "++++ done"


