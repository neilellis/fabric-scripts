#!/bin/sh
#todo: move this into a common script and convert all to POSH

D=`dirname "$1"`
B=`basename "$1"`
TARGET="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`/$B"

if [ -z "$FABRIC_NAME" ] ; then
    export FABRIC_NAME=default
fi


rm -rf /tmp/sar-tmp
mkdir /tmp/sar-tmp
cd /tmp/sar-tmp
jar -xf $TARGET

$FABRIC_HOME/bin/posh << EOF
nim:policy -R osgi.resolved.bundle/slf4j.api osgi.active.bundle/com.paremus.util.logman
index sar:0 .
repos -l sar.xml
log-config -c
log-config -l info
repos
log-config -l debug
echo Validating ...
nim add -dtpv $2
EOF
