#!/usr/bin/expect

if [ ! -f ~/.ssh/id_rsa ];then
	ssh-keygen -t rsa -P "" -f ~/.ssh/id_ras
else
	echo "id_rsa has created ..."
fi

path=/home/ckx/.ssh/id_rsa
while read line
do
	user=`echo $line | cut -d " " -f 3`
	passwd=`echo $line | cut -d " " -f 4`
	ip=`echo $line | cut -d " " -f 1`
	port=`echo $line | cut -d " " -f 2`

	expect <<EOF
		set timeout 10
		spawn ssh-copy-id -p $port -i $path $user@$ip
	expect {
		"yes/no" { send "yes\n";exp_continue }
		"password" { send "$passwd\n"}
	}
	expect "password" { send "$passwd\n" }
EOF
done < hosts 
