from novaclient import client
nt = client.Client(2, 'suro', 'PASSWORD', 'admin', AUTH_URL)
servers = nt.servers.list(detailed=True, search_opts={'all_tenants': 1})
for s in servers:
    s.to_dict()



