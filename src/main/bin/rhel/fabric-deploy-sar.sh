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
echo Indexing SAR
nim:index sar:1 .
echo Serving SAR as OBR
httpURL= sfs 9985 sar .
nim:policy -R osgi.resolved.bundle/slf4j.api osgi.active.bundle/com.paremus.util.logman
log-config -c
log-config -l debug
echo Starting Management Fibre
fibre -I --fabric-name=$FABRIC_NAME
fabric:connect
echo Loading Bundles
fabric:repos -lc \$httpURL/sar.xml
echo Reading System
fabric:import -f META-INF/system.xml
echo Deploying System
fabric:deploy $2
EOF


