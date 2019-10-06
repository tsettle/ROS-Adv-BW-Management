/queue type
add kind=pcq name=3_down pcq-classifier=dst-address pcq-rate=3M
add kind=pcq name=3_up pcq-classifier=src-address pcq-rate=384k
add kind=pcq name=6_down pcq-classifier=dst-address pcq-rate=6M
add kind=pcq name=6_up pcq-classifier=src-address pcq-rate=768k
add kind=pcq name=10_down pcq-classifier=dst-address pcq-rate=10M
add kind=pcq name=10_up pcq-classifier=src-address pcq-rate=2M
add kind=pcq name=25_down pcq-classifier=dst-address pcq-rate=25M
add kind=pcq name=25_up pcq-classifier=src-address pcq-rate=3M
add kind=pcq name=64k_up pcq-classifier=dst-address pcq-rate=64k
add kind=pcq name=64k_down pcq-classifier=src-address pcq-rate=64k

/queue simple
add limit-at=20M/100M max-limit=30M/150M name=Main target=ether2
add max-limit=10M/10M name="Special Customer" parent=Main target=100.65.28.254/32
add name=3M packet-marks=3M parent=Main queue=3_up/3_down
add name=6M packet-marks=6M parent=Main queue=6_up/6_down
add name=10M packet-marks=10M parent=Main queue=10_up/10_down
add name=25M packet-marks=25M parent=Main queue=25_up/25_down
add name=64k packet-marks=UNKNOWN parent=Main queue=64k_up/64k_up

/ip firewall filter
add action=drop chain=forward src-address-list=DISCO

/ip firewall address-list
add address=100.65.28.254 comment="Special Customer" list=SIMPLE

/ip firewall mangle
add action=mark-packet chain=postrouting dst-address-list=SIMPLE new-packet-mark=SIMPLE out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=SIMPLE packet-mark=no-mark passthrough=no src-address-list=SIMPLE
add action=mark-packet chain=postrouting dst-address-list=25M new-packet-mark=25M out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=25M packet-mark=no-mark passthrough=no src-address-list=25M
add action=mark-packet chain=postrouting dst-address-list=10M new-packet-mark=10M out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=10M packet-mark=no-mark passthrough=no src-address-list=10M
add action=mark-packet chain=postrouting dst-address-list=6M new-packet-mark=6M out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=6M packet-mark=no-mark passthrough=no src-address-list=6M
add action=mark-packet chain=postrouting dst-address-list=3M new-packet-mark=3M out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=3M packet-mark=no-mark passthrough=no src-address-list=3M
add action=add-src-to-address-list address-list=UNKNOWN address-list-timeout=10m chain=forward in-interface=ether2 packet-mark=no-mark src-address-list=!UNKNOWN

