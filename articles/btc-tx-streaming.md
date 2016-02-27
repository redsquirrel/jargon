[tag: learnings]
[tag: bitcoin]
[tag: ruby]

# Bitcoin Padawan finally writes some code

I've been exploring the Bitcoin ecosystem for the last two months. My [previous](http://jargon.io/redsquirrel/learnings-january) [posts](http://jargon.io/redsquirrel/learnings-mid-february) are representative of most of my time thus far: lots and lots of reading. The vast majority of that reading has been reading papers and blog posts. Over the last couple weeks, though, I started reading more code.

My [21 computer](http://21.co) is full of Python. [Bitcoin core](https://github.com/bitcoin/bitcoin) is mostly C++. I've also looked at the [Lightning Network Daemon](https://github.com/LightningNetwork/lnd), which is in Go. Yet, like most people, I find it hard to learn something new while also learning a new language. So I keep coming back to Ruby, a langauge I've been reading and writing since 2002. Thankfully, there are some great open source Bitcoin libraries and applications written in Ruby, most notably, [Toshi](https://toshi.io/).

I find it incredibly motivating to write code that touches something real, so I got it into my head that I wanted to write a simple program that streams real-time Bitcoin transactions to my terminal in the same way that [Toshi streams them to the browser](https://bitcoin.toshi.io/). Thanks to Ruby, [the Toshi codebase](https://github.com/coinbase/toshi), and [the libraries it leverages](https://github.com/lian/bitcoin-ruby), I was able to do that in less than 80 lines of code, which you can view and comment on [here](https://gist.github.com/redsquirrel/bce4ffbf0c677ac78fa7).

If you'd like to run it yourself, you'll need to:

* Install Ruby (I'm running `2.2.4p230`)
* Install the following gems: `bitcoin-ruby` and `eventmachine`
* Have a working Internet connection

## How it works

I'm going to step through it line by line, in the approximate order of execution:

[snippet: btc_transaction_firehose.rb:1,5]

Here, I'm just requiring the different gems and libraries I needed to make this work. `bitcoin` and `eventmachine` are both gems, while `resolv` and `set` are in Ruby's standard library.

[snippet: btc_transaction_firehose.rb:66]

Skipping past `BitcoinTransactionReader` and `BitcoinTransactionDatabase` for a moment, I've defined the `MY_USER_AGENT_STRING` constant. Actually, you'll need to define it before this code will work. Replace `put_something_here` with a String that is uniquely yours. This will give the Bitcoin nodes you connect to a little information about who is connecting to them. We'll use this constant up in `BitcoinTransactionReader`.

[snippet: btc_transaction_firehose.rb:68,70]

We need to connect to the Bitcoin network, and the standard way of doing this is to select a random node out of a set of known addresses, and then grab a bunch of addresses from that node. We use the [bitcoin-ruby](https://github.com/lian/bitcoin-ruby) gem to get a random address from its `:dns_seeds`.

I don't actually understand DNS well enough to explain what's going on here: `Resolv::DNS.new.getresources(seed, Resolv::DNS::Resource::IN::A)`. If anyone wants to explain it via the [gist](https://gist.github.com/redsquirrel/bce4ffbf0c677ac78fa7) comments, feel free! Basically, though, we end up with around 8-14 IP addresses, all of which represent nodes in the Bitcoin network.