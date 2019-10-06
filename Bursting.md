# Add Bursting to Your Bandwidth Management System

Ok, as an ISP, you really want your customers to have the absolute best experience possible, but you also recognize that bandwidth, and especially spectrum, is a precious commodity that needs to be managed and preserved.  Towards that end, we can use bursting to help keep things in check.

So, we want to allow speeds up to 25Mbit/s for normal browsing behavior.  Pages, even heavy pages, or really anything for that matter, that can be loaded within 3 minutes (wow, that's generous), will load just as quick as you please.  Speedtests will show your advertised maximums.  Customers will be happy.

However, during update season, when everyone's computer starts downloading the latest and greatest version of it's OS, or you have a torrent freak on the network, you can keep your other users happy by preventing any one customer from taking too much for too long.

* pcq-rate - CIR or Constant Information Rate - Cruising speed
* pcq-burst-rate - MIR or Maximum Information Rate - Top speed
* pcq-burst-threshold - Average speed to re-arm the burst rate
* pcq-burst-time - Time to keep a rolling average to control when you can burst and for how long

Our packages will be modified to the following:

* 25M MIR / 10M CIR - Suitable for up to 3-4 streams @ 2Mbit/s each
* 10M MIR / 5M CIR - Suitable for 2 streams
* 6M MIR / 3M CIR - Suitable for 1 stream (maybe 2 with some buffering)
* 3M MIR / 1.5M CIR - Streaming is a joke... sell them more bandwidth

It's really not rocket science, just a few things to add to the configurations in the main tutorial.

```
/queue type
set [find where name="3_down"] pcq-burst-time=3m pcq-burst-rate=3M pcq-rate=1536k pcq-burst-threshold=1024k 
set [find where name="6_down"] pcq-burst-time=3m pcq-burst-rate=6M pcq-rate=3M pcq-burst-threshold=2M
set [find where name="10_down"] pcq-burst-time=3m pcq-burst-rate=10M pcq-rate=5M pcq-burst-threshold=3584k 
set [find where name="25_down"] pcq-burst-time=3m pcq-burst-rate=25M pcq-rate=10M pcq-burst-threshold=7M         

```

You migth also want to do the same for uploads:

```
set [find where name="3_up"] pcq-burst-time=3m pcq-burst-rate=384k pcq-rate=192k pcq-burst-threshold=128k
set [find where name="6_up"] pcq-burst-time=3m pcq-burst-rate=768k pcq-rate=384k pcq-burst-threshold=256k
set [find where name="10_up"] pcq-burst-time=3m pcq-burst-rate=2M pcq-rate=1M pcq-burst-threshold=768k
set [find where name="25_up"] pcq-burst-time=3m pcq-burst-rate=3M pcq-rate=1536k pcq-burst-threshold=1M
```

Here's the export with the full config:

```
/queue type
add kind=pcq name=3_down pcq-burst-rate=3M pcq-burst-threshold=1024k pcq-burst-time=3m pcq-classifier=dst-address pcq-rate=1536k
add kind=pcq name=3_up pcq-burst-rate=384k pcq-burst-threshold=128k pcq-burst-time=3m pcq-classifier=src-address pcq-rate=192k
add kind=pcq name=6_down pcq-burst-rate=6M pcq-burst-threshold=2M pcq-burst-time=3m pcq-classifier=dst-address pcq-rate=3M
add kind=pcq name=6_up pcq-burst-rate=768k pcq-burst-threshold=256k pcq-burst-time=3m pcq-classifier=src-address pcq-rate=384k
add kind=pcq name=10_down pcq-burst-rate=10M pcq-burst-threshold=3584k pcq-burst-time=3m pcq-classifier=dst-address pcq-rate=5M
add kind=pcq name=10_up pcq-burst-rate=2M pcq-burst-threshold=768k pcq-burst-time=3m pcq-classifier=src-address pcq-rate=1M
add kind=pcq name=25_down pcq-burst-rate=25M pcq-burst-threshold=7M pcq-burst-time=3m pcq-classifier=dst-address pcq-rate=10M
add kind=pcq name=25_up pcq-burst-rate=3M pcq-burst-threshold=1M pcq-burst-time=3m pcq-classifier=src-address pcq-rate=1536k
add kind=pcq name=64k_up pcq-classifier=dst-address pcq-rate=64k
add kind=pcq name=64k_down pcq-classifier=src-address pcq-rate=64k
```

All these numbers are what works for us.  You may need to tweak things a bit to meet your needs.

##  Notes on streaming

One thing that's critical on a WISP network, is educating your customers and managing their expectations.  If they configure their streaming services to use the lowest quality, they will have a much better experience.  Yeah, the quality of the video suffers, but remind them that Fixed Wireless, especially in rural areas, is all about compromise.  If they want something better, they have a few options:

* Write to the FCC and demand more spectrum for unlicensed use
* Write to their county government and demand they allow more towers to be built
* Offer to let you build a tower on their property
* Pony up the money for a fiber build

