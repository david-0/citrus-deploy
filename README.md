# configure environment
## postgre sql configuration
apt update
apt install postgresql

sudo -u postgres -i
createuser -P citrus

### Prod database
createdb -O citrus citrus

### Integration database
createdb -O citrus citrus-int
\q

## insert initial admin user
register user with the frontend
sudo -u postgres -i
psql citrus | citrus-int
insert into role (id,name) values ('1','admin');
insert into role (id,name) values ('2','sale');
insert into role (id,name) values ('3','guest');
insert into role (id,name) values ('4','store');
insert into user_roles_role ("userId", "roleId") values ('1', '1');

# configure systemd
sudo cp systemd/* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable node-set-cap
sudo systemctl enable citrus-prod
sudo systemctl enable citrus-int
sudo systemctl start node-set-cab
sudo systemctl start citrus-prod
sudo systemctl start citrus-int

[optional] add these lines to sudoers
Cmnd_Alias CITRUS_INT_CMD=/bin/systemctl start citrus-int, /bin/systemctl stop citrus-int
Cmnd_Alias CITRUS_PROD_CMD=/bin/systemctl start citrus-prod, /bin/systemctl stop citrus-prod
davidl ALL=(ALL) NOPASSWD: CITRUS_INT_CMD,CITRUS_PROD_CMD

# Allow Node to bind to port 80 without sudo
(https://gist.github.com/firstdoit/6389682)
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/node
--> added service above will do the job at every start (node-set-cap)

# letsencrypt on 88.99.118.38 (alixon)
##install certbot
https://certbot.eff.org/lets-encrypt/ubuntubionic-other
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install certbot

## run certbot initially
certbot certonly --standalone
>> email address >> david.leuenberger@gmx.ch
>> Agree >> yes
>> Share email >> no

## config node-server
cd /home/alixon/usr/davidl/website/citrus/certificate/ssl
ln -s /etc/letsencrypt/live/shop.el-refugio-denia.com/cert.pem
ln -s /etc/letsencrypt/live/shop.el-refugio-denia.com/privkey.pem
ln -s /etc/letsencrypt/live/shop.el-refugio-denia.com/chain.pem

## chmod permissions 
setfacl -m u:davidl:rx /etc/letsencrypt/archive
setfacl -m u:davidl:rx /etc/letsencrypt/live
setfacl -m u:davidl:r /etc/letsencrypt/archive/shop.el-refugio-denia.com/privkey1.pem

## pre and post hooks for renew certificate
During the renewal of the certificate the port 80 is needed. So there must be a script, that stops the node server and an otherone which starts him again.
cat > /etc/letsencrypt/renewal-hooks/pre/stopCitrusServer.sh << EOF
#!/bin/bash
systemctl stop citrus-prod
EOF
chmod 700 /etc/letsencrypt/renewal-hooks/pre/stopCitrusServer.sh
cat > /etc/letsencrypt/renewal-hooks/post/startCitrusServer.sh << EOF
#!/bin/bash
systemctl start citrus-prod
EOF
chmod 700 /etc/letsencrypt/renewal-hooks/post/startCitrusServer.sh





