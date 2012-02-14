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
cat > ./sar.repos << EOF
index.name: sar
sar;1:  http://localhost:9985/sar/sar.xml
EOF

$FABRIC_HOME/bin/posh << EOF
echo Indexing ...
nim:index sar:1 .
echo Loading ...
poshx:sfs 9985 sar .
nim:policy -R osgi.resolved.bundle/slf4j.api osgi.active.bundle/com.paremus.util.logman
log-config -c
log-config -l info
nim repos -l http://localhost:9985/sar/sar.xml
repos
log-config -l debug
echo Validating ...
nim add -dtpv $2
EOF
