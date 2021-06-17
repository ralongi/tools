# functions for running netperf in .bashrc

function nic-perf
{
        local time=$1
        if [[ $# -lt 1 ]]; then time=10; fi
        netperf -H 192.168.1.8 -L 192.168.1.7 -l $time
}

function ovs-perf
{
        local time=$1
        if [[ $# -lt 1 ]]; then time=10; fi
        netperf -H 192.168.100.8 -L 192.168.100.7 -l $time
}

