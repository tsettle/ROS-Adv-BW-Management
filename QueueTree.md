# Use a Queue Tree instead of Simple Queues

Exploring the difference between Simple Queues and Queue Trees.

I *think* I'm getting a complete apples-to-apples config here.  I do not personally use queue trees for bandwidth management any more, so am unable to test annything.

## Simple Queues

### Mangle Rules

```
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
```

### Simple Queues

```
/queue simple
add max-limit=40M/200M name=Main target=ether2
add max-limit=10M/10M name="Special Customer" parent=Main target=100.65.28.254/32
add name=3M packet-marks=3M parent=Main queue=3_up/3_down
add name=6M packet-marks=6M parent=Main queue=6_up/6_down
add name=10M packet-marks=10M parent=Main queue=10_up/10_down
add name=25M packet-marks=25M parent=Main queue=25_up/25_down
add name=64k packet-marks=UNKNOWN parent=Main queue=64k_up/64k_down
```

## Queue Tree

### Mangle Rules for Queue Tree

For the PCQ items, the number of mangle rules is identical, but insted of using a single pair of rules for non-standard queues, we now have to create a pair for each and every one of them.  In the event that you need to create a non-standard queue for multiple addresses, you'll also need to create a new address list.

The last 2 rules here are for marking unknown addresses so we can throttle them (alter the rules accordingly if you want to add them to an address list for a filter rule).

```
/ip firewall mangle
add action=mark-packet chain=postrouting dst-address=100.65.28.254 new-packet-mark=JOHN_SMITH_UP out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=JOHN_SMITH_DOWN packet-mark=no-mark passthrough=no src-address=100.65.28.254
add action=mark-packet chain=postrouting dst-address-list=25M new-packet-mark=25M_UP out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=25M_DOWN packet-mark=no-mark passthrough=no src-address-list=25M
add action=mark-packet chain=postrouting dst-address-list=10M new-packet-mark=10M_UP out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=10M_DOWN packet-mark=no-mark passthrough=no src-address-list=10M
add action=mark-packet chain=postrouting dst-address-list=6M new-packet-mark=6M_UP out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=6M_DOWN packet-mark=no-mark passthrough=no src-address-list=6M
add action=mark-packet chain=postrouting dst-address-list=3M new-packet-mark=3M_UP out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=3M_DOWN packet-mark=no-mark passthrough=no src-address-list=3M
add action=mark-packet chain=postrouting dst-address-list=UNKNOWN new-packet-mark=UNKNOWN_UP out-interface=ether2 packet-mark=no-mark passthrough=no
add action=mark-packet chain=prerouting in-interface=ether2 new-packet-mark=UNKNOWN_DOWN packet-mark=no-mark passthrough=no src-address-list=UNKNOWN
```

### Build your Queue Tree

Since each queue tree is unidirectional, we have to create separate uplaod and download queues.  Not a huge issue, just sometingn to keep in mind when adding custom queues.

```
/queue tree
add max-limit=40M name=Upload parent=ether3
add max-limit=200M name=Download parent=ether3
add name=3M_Upload packet-mark=3M_UP parent=Upload queue=3_up
add name=6M_Upload packet-mark=6M_UP parent=Upload queue=6_up
add name=10M_Upload packet-mark=10M_UP parent=Upload queue=10_up
add name=25M_Upload packet-mark=25M_UP parent=Upload queue=25_up
add name=3M_Downlaod packet-mark=3M_DOWN parent=Download queue=3_down
add name=6M_Downlaod packet-mark=6M_DOWN parent=Download queue=6_down
add name=10M_Downlaod packet-mark=10M_DOWN parent=Download queue=10_down
add name=25M_Downlaod packet-mark=25M_DOWN parent=Download queue=25_down
add max-limit=10M name="John Smith Upload" packet-mark=JOHN_SMITH_UP parent=Upload
add max-limit=10M name="John Smith Download" packet-mark=JOHN_SMITH_DOWN parent=Download
```

## Notes

One thing to note, is that if you're trying to manage a finite amount of bandwiidth, then every single packet on the connection must pass through the same queue (simple or tree).  You must choose which one you want to use and stick with it.  Personally, I find that using simple queues is worth the performnace hit.  My coworkers are able to cope with them easier without having to send me every single ticket when a custom queue needs to be created.

