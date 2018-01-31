#!/bin/bash

# So you think you can fuzz :)
CFUSER=`cat /boot/CFUSER.txt`
CFPASS=`cat /boot/CFPASS.txt`
CFHOST=`cat /boot/CFHOST.txt`

cd /usr/local/src

# DOWNLOAD TGZ
## DAEMONS     : home-iniac.tgz
wget --user $CFUSER --password $CFPASS https://$CFHOST/files/home-iniac.tgz
## WWW CONTENT : www-iniac.tgz
wget --user $CFUSER --password $CFPASS https://$CFHOST/files/www-iniac.tgz
## pylibftdi
wget --user $CFUSER --password $CFPASS https://$CFHOST/files/pylibftdi.tgz
tar -zxf pylibftdi.tgz -C /usr/local/lib/python2.7/dist-packages

# INSTALLING ALL MANDATORY PACKAGES
apt-get -y install python python-django uwsgi uwsgi-plugin-python python-xlsxwriter nginx-full sqlite3 libftdi-dev python-pyudev

# INSTALLING DAEMONS
ZHOME="/usr/local/"
cd $ZHOME
mkdir $ZHOME"/iniac/"
tar -zxvf /usr/local/src/home-iniac.tgz
sed -i "s|/home/pi|$ZHOME|g" $ZHOME"/iniac/config.xml"
sed -i "s|/home/pi|$ZHOME|g" $ZHOME"/iniac/iniac_base.py"
sed -i "s|/home/pi|$ZHOME|g" $ZHOME"/iniac/iniac_parse_cmd.py"

# INSTALLATION WWW
mkdir -p /var/www/iniac/iniac/
chown -R www-data.www-data /var/www/iniac
cd /var/www/
tar -zxvf /usr/local/src/www-iniac.tgz
echo BASE_PATH = $ZHOME"/iniac/" > /tmp/settings 
grep -v BASE_PATH /var/www/iniac/iniac/settings.py >> /tmp/settings
cat /tmp/settings > /var/www/iniac/iniac/settings.py

# NGINX CONF
./install-nginx-uwsgi.sh

# RC.LOCAL STARTING DAEMONS
grep -v exit /etc/rc.local > /tmp/rc
cat <<EOF >> /tmp/rc

sleep 10
/usr/bin/nohup python zhome/iniac/iniac_event_handler.py &

exit 0
EOF
cat /tmp/rc | sed "s|zhome|$ZHOME|g" > /etc/rc.local

# CLEANUP
rm -f /tmp/rc /tmp/settings

