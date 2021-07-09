#!/usr/bin/expect

if [ ! -f ~/.ssh/id_rsa ];then
	ssh-keygen -t rsa -P "" -f ~/.ssh/id_ras
else
	echo "id_rsa has created ..."
fi
username=`whoami`
user="chenkangxin"
passwd="ckx"
ip="10.22.148.86"
for i in {0..6}
do
	expect <<EOF
		set timeout 10
		spawn ssh-copy-id l${i}
	expect {
		"yes/no" { send "yes\n";exp_continue }
		"password" { send "$passwd\n"}
	}
	expect "password" { send "$passwd\n" }
EOF
done
