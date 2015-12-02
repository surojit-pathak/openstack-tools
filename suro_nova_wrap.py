#! /usr/bin/python
import os

from novaclient import client

class SuroNovaWrap(object):
    def _build_connection(self):
        self.client = client.Client(2, self.user, 'NOPASSWORD', self.tenant,
                                    self.auth_url)
        servers = self.client.servers.list(detailed=True,
                                           search_opts={'all_tenants': 1})
        for s in servers:
            self.sdict[s.name] = s

    def _get_credentials(self):
	try:
	    self.user = os.environ['OS_USERNAME']
	except:
	    raise
	try:
	    self.tenant = os.environ['OS_TENANT_NAME']
	except:
	    raise
	try:
	    self.auth_url = os.environ['OS_AUTH_URL']
	except:
	    raise

    def __init__(self):
        self.sdict = {}
        self._get_credentials()
        self._build_connection()

    def flavors(self):
        for f in self.client.flavors.list():
            fdict = f.to_dict()
            print("{flv}[{id}](CPU/RAM/DISK): {cpu}/{ram}/{disk}".format(
                  flv=fdict['name'], id=fdict['id'], cpu=fdict['vcpus'], 
                  ram=fdict['ram'], disk=fdict['disk']))

