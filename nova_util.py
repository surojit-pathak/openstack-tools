#! /usr/bin/python
import os

from novaclient import client

sdict = {}
def os_build(user, tenant, auth_url):
    nt = client.Client(2, user, 'NOPASSWORD', tenant, auth_url)
    servers = nt.servers.list(detailed=True, search_opts={'all_tenants': 1})
    for s in servers:
        global sdict
        sdict[s.name] = s

def os_query():
    property_map = {
        'host': 'OS-EXT-SRV-ATTR:host'
    } 
    global sdict
    while True:
        vm = raw_input('Enter the name of the VM:')
        param = raw_input('Enter the property of the VM:')
        prop = property_map[param]
        sdetail = sdict[vm].to_dict()
        print sdetail[prop], sdetail['username']

if __name__ == '__main__':
    try:
        user = os.environ['OS_USERNAME']
    except:
        raise
    try:
        tenant = os.environ['OS_TENANT_NAME']
    except:
        raise
    try:
        auth_url = os.environ['OS_AUTH_URL']
    except:
        raise
    
    os_build(user, tenant, auth_url)
    os_query()
