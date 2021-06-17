#!/bin/bash

# Usage
# ./script bridge port_unrestricted port_restricted

# port_restricted can either be the openflow port id, or the name of
# the port on the bridge (ie: either a number, or the name 'em1')

if [ "$BRIDGE" == "" ]; then
   BRIDGE="$1"
   shift
fi

if [ "$INPUT_PORT" == "" ]; then
   INPUT_PORT="$1"
   shift
fi

if [ "$RESTRICTED_PORT" == "" ]; then
   RESTRICTED_PORT="$1"
   shift
fi

echo "Restricting all tcp for OVS-port ${RESTRICTED_PORT}, through ${INPUT_PORT}"
echo "Bridge = ${BRIDGE}"

# Resolve names
if ! echo "${RESTRICTED_PORT}" | egrep '^[0-9]+$' >/dev/null 2>&1; then
    OLD_RESTRICTED=$RESTRICTED_PORT
    RESTRICTED_PORT=$(ovs-ofctl dump-ports-desc $BRIDGE | grep \($RESTRICTED_PORT\) | sed -e 's@(.*@@g' -e 's@ @@g')
    echo "Restricted port resolved to [$RESTRICTED_PORT] from $OLD_RESTRICTED"
fi

if ! echo "${INPUT_PORT}" | egrep '^[0-9]+$' >/dev/null 2>&1; then
    OLD_INPUT=$INPUT_PORT
    INPUT_PORT=$(ovs-ofctl dump-ports-desc $BRIDGE | grep \($INPUT_PORT\) | sed -e 's@(.*@@g' -e 's@ @@g')
    echo "Input port resolved to [$INPUT_PORT] from $OLD_INPUT"
fi

# Set up conntrack for tcp where RESTRICTED_PORT can only respond to valid tcp
# from INPUT_PORT

# clear all flows on the bridge
ovs-ofctl del-flows $BRIDGE

# first setup arp and drop
ovs-ofctl add-flow $BRIDGE "table=0,priority=1,action=drop"
ovs-ofctl add-flow $BRIDGE "table=0,priority=10,arp,action=normal"

# all ip not tracked, move to table 1
ovs-ofctl add-flow $BRIDGE "table=0,priority=100,ip,ct_state=-trk,action=ct(table=1)"

# first, input on the input port, new and established go through to restricted port
ovs-ofctl add-flow $BRIDGE "table=1,in_port=${INPUT_PORT},tcp,ct_state=+trk+new,actions=ct(zone=10,commit),${RESTRICTED_PORT}"
ovs-ofctl add-flow $BRIDGE "table=1,in_port=${INPUT_PORT},tcp,ct_state=+trk+est,actions=${RESTRICTED_PORT}"

# now, input on the restricted port, only established go through
ovs-ofctl add-flow $BRIDGE "table=1,in_port=${RESTRICTED_PORT},tcp,ct_state=+trk+new,actions=drop"
ovs-ofctl add-flow $BRIDGE "table=1,in_port=${RESTRICTED_PORT},tcp,ct_state=+trk+est,actions=${INPUT_PORT}"

ovs-ofctl dump-flows $BRIDGE
