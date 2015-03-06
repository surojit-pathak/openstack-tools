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
