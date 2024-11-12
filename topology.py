#!/usr/bin/python3
import time
import socket
import mininet.clean as Cleanup
from mininet.net import Mininet
from mininet.node import RemoteController
from mininet.node import OVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel

def get_ip(name):
    for i in range(60):
        try:
            ip = socket.gethostbyname(name)
            break
        except Exception as exc:
            print(f"Failed resolving {name}: {exc}. Trying again {i}...")
            time.sleep(2)
    else:
        raise ValueError(f"Could not resolve {name}")
    return ip

def custom_topo():
    net = Mininet(topo=None, build=False, controller=RemoteController, switch=OVSSwitch)

    # amlight
    amlight_c1 = net.addController('am_c1', controller=RemoteController, ip=get_ip("amlight"), port=6653)
    amlight_c1.start()
    amlight_s1 = net.addSwitch('amlightS1', dpid='0000000000000001')
    amlight_h1 = net.addHost('amlightH1', mac='00:00:00:00:00:01')
    net.addLink(amlight_h1, amlight_s1, port1=1, port2=50)

    # sax
    sax_c1 = net.addController('sax_c1', controller=RemoteController, ip=get_ip("sax"), port=6653)
    sax_c1.start()
    sax_s1 = net.addSwitch('saxS1', dpid='0000000000000002')
    sax_h1 = net.addHost('saxH1', mac='00:00:00:00:00:02')
    net.addLink(sax_h1, sax_s1, port1=1, port2=50)

    # tenet
    tenet_c1 = net.addController('te_c1', controller=RemoteController, ip=get_ip("tenet"), port=6653)
    tenet_c1.start()
    tenet_s1 = net.addSwitch('tenetS1', dpid='0000000000000003')
    tenet_h1 = net.addHost('tenetH1', mac='00:00:00:00:00:03')
    net.addLink(tenet_h1, tenet_s1, port1=1, port2=50)

    # internet2
    internet2_c1 = net.addController('i2_c1', controller=RemoteController, ip=get_ip("internet2"), port=6653)
    internet2_c1.start()
    internet2_s1 = net.addSwitch('i2S1', dpid='0000000000000004')
    internet2_h1 = net.addHost('i2H1', mac='00:00:00:00:00:04')
    net.addLink(internet2_h1, internet2_s1, port1=1, port2=50)

    # esnet
    esnet_c1 = net.addController('es_c1', controller=RemoteController, ip=get_ip("esnet"), port=6653)
    esnet_c1.start()
    esnet_s1 = net.addSwitch('esnetS1', dpid='0000000000000005')
    esnet_h1 = net.addHost('esnetH1', mac='00:00:00:00:00:05')
    net.addLink(esnet_h1, esnet_s1, port1=1, port2=50)

    # geant_london
    geant_london_c1 = net.addController('glo_c1', controller=RemoteController, ip=get_ip("geant_london"), port=6653)
    geant_london_c1.start()
    geant_london_s1 = net.addSwitch('geantUKS1', dpid='0000000000000006')
    geant_london_h1 = net.addHost('geantUKH1', mac='00:00:00:00:00:06')
    net.addLink(geant_london_h1, geant_london_s1, port1=1, port2=50)

    # geant_france
    geant_france_c1 = net.addController('gfr_c1', controller=RemoteController, ip=get_ip("geant_france"), port=6653)
    geant_france_c1.start()
    geant_france_s1 = net.addSwitch('geantFRS1', dpid='0000000000000007')
    geant_france_h1 = net.addHost('geantFRH1', mac='00:00:00:00:00:07')
    net.addLink(geant_france_h1, geant_france_s1, port1=1, port2=50)

    # lhc
    lhc_c1 = net.addController('lhc_c1', controller=RemoteController, ip=get_ip("lhc"), port=6653)
    lhc_c1.start()
    lhc_s1 = net.addSwitch('lhcS1', dpid='0000000000000008')
    lhc_h1 = net.addHost('lhcH1', mac='00:00:00:00:00:08')
    net.addLink(lhc_h1, lhc_s1, port1=1, port2=50)

    # ********************************************** Inter-OXP links ***********************************************
    net.addLink(amlight_s1, sax_s1, port1=10, port2=10)
    net.addLink(amlight_s1, tenet_s1, port1=11, port2=11)
    net.addLink(sax_s1, tenet_s1, port1=12, port2=12)
    net.addLink(amlight_s1, esnet_s1, port1=13, port2=13)
    net.addLink(sax_s1, internet2_s1, port1=14, port2=14)
    net.addLink(esnet_s1, internet2_s1, port1=15, port2=15)
    net.addLink(internet2_s1, lhc_s1, port1=16, port2=16)
    net.addLink(esnet_s1, geant_london_s1, port1=17, port2=17)
    net.addLink(lhc_s1, geant_london_s1, port1=18, port2=18)
    net.addLink(lhc_s1, geant_france_s1, port1=19, port2=19)

    amlight_s1.start([amlight_c1])
    sax_s1.start([sax_c1])
    tenet_s1.start([tenet_c1])
    internet2_s1.start([internet2_c1])
    esnet_s1.start([esnet_c1])
    geant_london_s1.start([geant_london_c1])
    geant_france_s1.start([geant_france_c1])
    lhc_s1.start([lhc_c1])

    net.build()
    CLI(net)
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')  # for CLI output
    custom_topo()
    Cleanup.cleanup()
