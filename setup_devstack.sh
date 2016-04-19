#!/bin/bash

source ~/Tools/nova_utils.sh
source ~/Tools/fabric/fabwrap.sh
source ~/rcS/bashrc
source ~/github-surojit-pathak/rcS/bashrc

function execute_cmd ()
{
    # echo "Executing - \" $@ \" "
    "$@"
    if [ $? -ne 0 ]; then
        echo Failed exe - \""$@"\" 
        exit 1
    fi
}


SSH_CONF_FILE=~/.ssh/config
# If we do not delete the conf file. The old IP may be there.
# This causes the ssh to go through with warning.
rm $SSH_CONF_FILE
if [ ! -f $SSH_CONF_FILE ]; then
     echo "Host git.corp.blah.com" > $SSH_CONF_FILE
     echo "  StrictHostKeyChecking no" >> $SSH_CONF_FILE
     echo "  IdentityFile ~/.ssh/id_rsa" >> $SSH_CONF_FILE
fi

set -v

SUROM_BARE_METAL=${SUROM_BARE_METAL:-"False"}
SUROM_DEPLOY_DEVSTACK=${SUROM_DEPLOY_DEVSTACK:-"True"}

SUROM_INSTANCE_NAME=${SUROM_INSTANCE_NAME:-"suro-testvm"}
SUROM_INSTANCE_FLAVOR=${SUROM_INSTANCE_FLAVOR:-"large"}
SUROM_INSTANCE_IMAGE=${SUROM_INSTANCE_IMAGE:-"linux-7"}

if [ $SUROM_BARE_METAL = "False" ]; then
    cd # For avoiding local keyring
    present=$(nova list | grep $SUROM_INSTANCE_NAME | wc -l)
    if [ $present -eq 0 ]; then 
        execute_cmd nova boot --image ${SUROM_INSTANCE_IMAGE} --flavor $SUROM_INSTANCE_FLAVOR $SUROM_INSTANCE_NAME --user-data ~/rcS/RHEL7.init
        # nova_poll_ssh_rdy $SUROM_INSTANCE_NAME
        sleep 150
    fi

    # Check sanity
    status=$( nova list | grep $SUROM_INSTANCE_NAME | awk '{print $6}' )
    if [ $status != "ACTIVE" ]; then echo "VM is in wrong state!"; nova show $SUROM_INSTANCE_NAME; nova delete $SUROM_INSTANCE_NAME; exit 1; fi

    INST_IP=$( nova list | grep $SUROM_INSTANCE_NAME | awk '{print $12}'| cut -f2 -d= )
else
    INST_IP=${SUROM_BARE_METAL}
fi

echo "Host $INST_IP" >> $SSH_CONF_FILE
echo "  StrictHostKeyChecking no" >> $SSH_CONF_FILE
echo "  IdentityFile ~/.ssh/id_rsa" >> $SSH_CONF_FILE

grep -q $INST_IP ~/.ssh/known_hosts
if [ $? -eq 0 ]; then suro_rem_old_ssh_fingerprint $INST_IP; fi

HOSTLIST=`mktemp`
echo $INST_IP > ${HOSTLIST}

# declare -f suro_init_vm | grep "^\ " | while read -r line; do fabwrap_node_run_cmd "$line" ${HOSTLIST} ; done
fabwrap_node_run_cmd "sudo yum install -y git" ${HOSTLIST}
fabwrap_node_run_cmd "mkdir github-surojit-pathak" ${HOSTLIST}
fabwrap_node_run_cmd "git clone https://github.com/surojit-pathak/rcS.git github-surojit-pathak/rcS" ${HOSTLIST}
fabwrap_node_run_cmd "chmod +x github-surojit-pathak/rcS/bootstrapme.sh" ${HOSTLIST}
fabwrap_node_run_cmd "github-surojit-pathak/rcS/bootstrapme.sh" ${HOSTLIST}

ssh-add -l 
if [ $? -ne 0 ]; then
    echo "SSH Agent forwarding is not properly set up"
    echo "There is no point to proceed further ..."
    rm -f ${HOSTLIST}
    exit 1    
fi

# Setup Yahoo!
fabwrap_node_run_cmd "echo \"Host git.corp.blah.com\" > ~/.ssh/config" ${HOSTLIST}
fabwrap_node_run_cmd "echo \"  StrictHostKeyChecking no\" >> ~/.ssh/config" ${HOSTLIST}
#fabwrap_node_run_cmd "echo \"  IdentityFile ~/.ssh/id_rsa\" >> ~/.ssh/config" ${HOSTLIST}
fabwrap_node_run_cmd "chmod 600 ~/.ssh/config" ${HOSTLIST}
fabwrap_node_run_cmd "rm -rf rcS; git clone git@git.corp.blah.com:suro/rcS.git" ${HOSTLIST}
fabwrap_node_run_cmd "chmod +x rcS/bootmestrap.sh" ${HOSTLIST}
fabwrap_node_run_cmd "rcS/bootmestrap.sh" ${HOSTLIST}

# devstack
# declare -f setup_devstack | grep "^\ " | while read -r line; do fabwrap_node_run_cmd "$line" ${HOSTLIST} ; done
if [ $SUROM_DEPLOY_DEVSTACK = "True" ]; then
    fabwrap_node_run_cmd "chmod +x github-surojit-pathak/rcS/magnum_devstack_setup.sh" ${HOSTLIST}
    fabwrap_node_run_cmd "github-surojit-pathak/rcS/magnum_devstack_setup.sh" ${HOSTLIST}
fi

rm -f ${HOSTLIST}
set +v
