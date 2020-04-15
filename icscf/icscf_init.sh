#!/bin/bash
while true; do
	echo 'Waiting for MySQL to start.'
	echo '' | nc -w 1 $MYSQL_IP 3306 && break
	sleep 1
done

sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/kamailio_icscf.cfg
sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.xml

DAEMON=/usr/local/sbin/kamailio
NAME=kamailio_icscf
HOMEDIR=/var/run/$NAME
PIDFILE=$HOMEDIR/$NAME.pid
CFGFILE=/etc/$NAME/$NAME.cfg
USER=kamailio
GROUP=kamailio
SHM_MEMORY=64
PKG_MEMORY=8
DUMP_CORE=no

mkdir -p $HOMEDIR

set +e
out=$($DAEMON -f $CFGFILE -M $PKG_MEMORY -c 2>&1 > /dev/null)
retcode=$?
set -e
if [ "$retcode" != '0' ]; then
    echo "Not starting $DESC: invalid configuration file!"
    echo "$out"
    exit 1
fi

RADIUS_SEQ_FILE="$HOMEDIR/kamailio_radius.seq"
chown ${USER}:${GROUP} $HOMEDIR

if [ ! -f $RADIUS_SEQ_FILE ]; then
    touch $RADIUS_SEQ_FILE
fi

chown ${USER}:${GROUP} $RADIUS_SEQ_FILE
chmod 660 $RADIUS_SEQ_FILE

$DAEMON -f $CFGFILE -P $PIDFILE -D -E -e
