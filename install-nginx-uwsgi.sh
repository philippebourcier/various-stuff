#!/bin/bash

rm /etc/nginx/sites-enabled/*

cat <<EOF >> /etc/nginx/sites-enabled/iniac
upstream django {
    server unix:/var/run/uwsgi/app/iniac.wsgi/socket;
}
server {
        listen 80 default_server;
        root /var/www/iniac;
        server_name _;
        location /static {
                alias /var/www/iniac/static/;
        }
        location / {
                uwsgi_pass  django;
                include uwsgi_params;
        }
}
EOF

cat <<EOF >> /etc/uwsgi/apps-enabled/iniac.wsgi.ini 
[uwsgi]
plugins=python
post-buffering=1
harakiri=28
chdir=/var/www/iniac
module=iniac.wsgi:application
master=True
pidfile=/tmp/iniac.pid
vacuum=True
max-requests=5000
EOF

echo 'disable-logging=True' >> /usr/share/uwsgi/conf/default.ini

