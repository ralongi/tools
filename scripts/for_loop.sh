
# Juniper QFX5100
for i in $( seq 0 23 ); do 
	echo "set interfaces xe-0/0/$i native-vlan-id 1"
	echo "set interfaces xe-0/0/$i unit 0 family ethernet-switching interface-mode trunk"
	echo "set interfaces xe-0/0/$i unit 0 family ethernet-switching vlan members all"
done

# Juniper EX4550
for i in $( seq 0 31 ); do 
	echo "set interfaces xe-0/0/$i unit 0 family ethernet-switching native-vlan-id default"
done

for i in $( seq 0 1 ); do 
	echo "set interfaces xe-0/0/$i unit 0 family ethernet-switching native-vlan-id default"
	echo "set interfaces xe-0/0/$i unit 0 family ethernet-switching port-mode access"
	echo "set interfaces xe-0/0/$i unit 0 family ethernet-switching vlan members all"
done

