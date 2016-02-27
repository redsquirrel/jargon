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

I'm going to step through [the program](https://gist.github.com/redsquirrel/bce4ffbf0c677ac78fa7) line by line, in the approximate order of execution:

[snippet: btc_transaction_firehose.rb:1,5]

Here, I'm just requiring the different gems and libraries I needed to make this work. `bitcoin` and `eventmachine` are both gems, while `resolv` and `set` are in Ruby's standard library.

[snippet: btc_transaction_firehose.rb:66]

Skipping past `BitcoinTransactionReader` and `BitcoinTransactionDatabase` for a moment, I've defined the `MY_USER_AGENT_STRING` constant. Actually, you'll need to define it before this code will work. Replace `put_something_here` with a String that is uniquely yours. This will give the Bitcoin nodes you connect to a little information about who is connecting to them. We'll use this constant up in `BitcoinTransactionReader`.

[snippet: btc_transaction_firehose.rb:68,70]

In order to stream transactions, we'll need to connect to the Bitcoin network. The standard way of making an intial connection is to select a random node out of a set of known addresses, and then grab a bunch of addresses from that node. We use the [bitcoin-ruby](https://github.com/lian/bitcoin-ruby) gem to get a random address from its `:dns_seeds`.

I don't actually understand DNS well enough to explain what's going on here: `Resolv::DNS.new.getresources(seed, Resolv::DNS::Resource::IN::A)`. If anyone wants to explain it via the [gist](https://gist.github.com/redsquirrel/bce4ffbf0c677ac78fa7) comments, feel free! Ultimately, we end up with around 8-14 IP addresses, all of which represent nodes in the Bitcoin network. (Note: some of the `:dns_seeds` are unresponsive, so you'll need to kill your program and try again when you get them.)

[snippet: btc_transaction_firehose.rb:71]

We initialize a `BitcoinTransactionDatabase`, which is just a little class that wraps a Ruby `Set`. As you'll see, every time we receive a transaction, we'll pass it to the database to process. We need to initialize the "database" up in the global scope because we're about to jam it into a bunch of different connections to Bitcoin nodes.

[snippet: btc_transaction_firehose.rb:73,78]

We use Ruby's [EventMachine](https://github.com/eventmachine/eventmachine) to do all of the hard networking stuff. I read a nice EventMachine tutorial [here](http://20bits.com/article/an-eventmachine-tutorial). (Thanks Jesse!)

We loop through all of the IP addresses, connecting to each one on the default Bitcoin port of `8333`. We pass in the `BitcoinTransactionReader` module (which EventMachine mixes into its [Connection](http://www.rubydoc.info/gems/eventmachine/EventMachine/Connection) class), and also pass in the address (again) and our little database. These are passed to the `initialize` method defined in `BitcoinTransactionReader`.

[snippet: btc_transaction_firehose.rb:7,12]

A `BitcoinTransactionReader` will be created for *each* connection we make to a Bitcoin node. We set it up with its instance variables. The interesting one is `Bitcoin::Protocol::Parser.new(self)`. The reader passes *itself* into the parser, and we'll see how that works in a moment.

At a high level, the `BitcoinTransactionReader` needs to hook into two libraries. It needs to implement some of the EventMachine connection hooks as well as implementing some of the `Bitcoin::Protocol::Parser` methods.

[snippet: btc_transaction_firehose.rb:15,22]

Immediately after the connection is made to the Bitcoin node, EventMachine calls `post_init`. We use EventMachine's `send_data` method to reply with our version information. Based on what I learned from Toshi, this appears to start a handshake between us and the Bitcoin node.

[snippet: btc_transaction_firehose.rb:24,26]

Any data transmitted from the Bitcoin node is simply passed into the `Bitcoin::Protocol::Parser`. Remember that we passed the `BitcoinTransactionReader` into the parser, so as the data is parsed, the parser will callback to our reader...

[snippet: btc_transaction_firehose.rb:30,48]

The rest of these methods are all called by the parser, which I harvested from Toshi. I don't yet fully understand what `on_ping`, `on_inv_transaction`, and `on_inv_block_v2` are doing, and how they fit into the interactions. `on_tx` is the important one, and that's where we pass the transaction (tx) to our little "database".

[snippet: btc_transaction_firehose.rb:52,64]

Our dumb little database is just a `Set` that we use to track whether we've already seen a transaction. Since we're connecting to around 10 nodes, we're going to see a bunch of duplicate transactions. I'd like to show each transaction once, and only once. So if it's the first time we've seen it, we store the [transaction id hash](https://bitcoin.org/en/glossary/txid). Then we have a little fun and add up the total [output](https://en.bitcoin.it/wiki/Transaction#Output) value of the transaction and print it to the screen!

Head over to the [gist](https://gist.github.com/redsquirrel/bce4ffbf0c677ac78fa7), try it out, and leave a comment!