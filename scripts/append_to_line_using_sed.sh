for i in ls exec*.sh; do
    if [[ ! $(grep runtest $i | grep crash_check) ]]; then
        sed -i.bak '/runtest/s/$/ --append-task="\/kernel\/networking\/openvswitch\/crash_check {dbg_flag=set -x}"/'  $i
    fi
done
