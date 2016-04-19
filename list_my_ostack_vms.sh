#!/bin/bash
#set -x
trap "exit" INT
FSELF=`readlink -e "${BASH_SOURCE[0]}"`
FDIR=`dirname $FSELF`

user=$USER
read -p "OpenStack Password for $user: " -s passw; echo

declare -a tenants=("suro" "admin")
declare -a auth_urls=("http://keystone.blah.com:5000/v2.0")

cd
for auth_url in "${auth_urls[@]}"
do
    for tenant in "${tenants[@]}"
    do
        nova --os-auth-url $auth_url --os-tenant-name $tenant --os-username $user --os-password $passw list | grep -q $user
        if [ $? -eq 0 ]; then
            cluster=`echo $auth_url | cut -f 3 -d\/ | cut -f 6 -d.`
            printf "\n$user's VM's as tenant $tenant on $cluster --\n"
            nova --os-auth-url $auth_url --os-tenant-name $tenant --os-username $user --os-password $passw list | grep $user
        fi
    done
done

