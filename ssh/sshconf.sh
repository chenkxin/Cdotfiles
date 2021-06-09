#!/usr/bin/bash

while read line
do
	alias=`echo $line | cut -d " " -f 5`
	ip=`echo $line | cut -d " " -f 1`
	port=`echo $line | cut -d " " -f 2`
	user=`echo $line | cut -d " " -f 3`
	echo "Host $alias" >> ~/.ssh/config
	echo "    HostName $ip" >> ~/.ssh/config
	echo "    Port $port" >> ~/.ssh/config
	echo "    User $user" >> ~/.ssh/config
	echo "    IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config
done < hosts
