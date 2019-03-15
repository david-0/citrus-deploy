#!/bin/bash

server=davidl@88.99.118.38

s=$(readlink -f $0)
cd ${s%/*}

echo "++++ build client" && \
	cd ../citrus-client && \
	npm run build-prod && \
	ssh $server << EOF 
	echo "---- clean dist" && \\
	rm -rf ~/website/citrus/citrus-client/dist
	echo "---- create dist" && \\
	mkdir -p ~/website/citrus/citrus-client/dist
EOF
[ $? -eq 0 ] && \
	echo "++++ copy site" && \
	scp -r dist $server:~/website/citrus/citrus-client && \
	ssh $server << EOF 
	cd ~/website/citrus/citrus-client && \\
	echo "---- client: git pull" && \\
	git pull && \\
	echo "---- client: run deploy" && \\
	npm run deploy
EOF
[ $? -eq 0 ] && \
	echo "++++ build server" && \
	ssh $server << EOF
	cd ~/website/citrus/citrus-server && \\
	echo "---- server: run reload" && \\
	npm run reload
EOF
[ $? -eq 0 ] && \
	echo "++++ done"


