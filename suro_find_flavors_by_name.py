import os
import sys

dir=os.path.dirname(os.path.abspath(__file__))
sys.path.append(dir)

import suro_nova_wrap as snw

c1 = snw.SuroNovaWrap()

vm_name_prefix = raw_input("Enter the VM-name-prefix?")
for s in c1.sdict:
    if s.startswith(vm_name_prefix):
        vm_flavor = c1.sdict[s].to_dict()['flavor']
        print("{vm}: Flavor {flv}".format(vm=s, flv=vm_flavor['id']))

c1.flavors()

