#!/usr/bin/env bash

# Wrapper utility over novaclient

function suro_nova_delete_all_instances () 
{ 
    cd
    for inst in `nova list | grep $USER | awk '{print $2}'`;
    do
        nova delete $inst
    done
}

function suro_novawrap_list_vm_with_hv ()
{
    cd
    for iid in `nova list | grep ACTIVE | awk '{print $2}'`;
    do
        hv=`nova show $iid | grep hypervisor_hostname | awk '{print $4}'`
        name=`nova show $iid | grep "^| name" | awk '{print $4}'`
        hostname=`nova show $iid | grep "^| hostname" | awk '{print $4}'`
        tenantid=`nova show $iid | grep "^| tenant_id" | awk '{print $4}'`
        # echo $name, $hostname, $hv, $tenantid
        printf "Host:%-32s, HV: %-32s, Tenant-Id: %s, Name: %s\n" $hostname $hv $tenantid $name
    done
}

function nova_poll_ssh_rdy ()
{
    echo $1;
    while [ 1 -eq 1 ]; do
        nova console-log $1 | grep " sshd:";
        if [ $? -eq 0 ]; then
            return;
        fi;
        sleep 2;
        echo "Another attempt\n";
    done
}

function nova_suro_hv_check_instance ()
{
    for i in `find . -name console.log`;
    do
        dir=`dirname $i`;
        inst=`grep "nova:name" $dir/libvirt.xml | cut -f2 -d\> | cut -f1 -d\<`;
        echo $inst "-----";
        grep "init-local" $i;
    done
}
