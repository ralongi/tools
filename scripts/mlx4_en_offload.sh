if [[ $rhel_version == 7 && $driver == mlx4_en ]]; then
	echo "options mlx4_core log_num_mgm_entry_size=-1 debug_level=1" > /etc/modprobe.d/mlx4_core.conf
	rmmod mlx4_en mlx4_ib mlx4_core; modprobe mlx4_core
fi
