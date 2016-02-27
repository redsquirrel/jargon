[tag: learnings]
[tag: bitcoin]
[tag: ruby]

# Bitcoin Padawan finally writes some code

I've been exploring the Bitcoin ecosystem for the last two months. My [previous](http://jargon.io/redsquirrel/learnings-january) [posts](http://jargon.io/redsquirrel/learnings-mid-february) are representative of most of my time thus far: lots and lots of reading. The vast majority of that reading has been reading papers and blog posts. Over the last couple weeks, though, I started reading more code.

My 21 computer is full of Python. Bitcoin core is mostly C++. I've also looked at the Lightning Network Daemon, which is in Go. But like most people, I find it hard to learn something new while also learning a new language. So I keep coming back to Ruby, a langauge I've been reading and writing since 2002. Thankfully, there are some create open source Bitcoin libraries and applications written in Ruby, most notably, Toshi.

I find it incredibly motivating to write code that touches something real, so I got it into my head that I wanted to write a simple program that streams real-time Bitcoin transactions to my terminal. Thanks to Ruby, the Toshi codebase, and the libraries it leverages, I was able to do that in [less than 80 lines of code](https://gist.github.com/redsquirrel/bce4ffbf0c677ac78fa7).

If you'd like to run it yourself, you'll need to:

* Install Ruby (I'm running `2.2.4p230`)
* Install the following gems: `bitcoin-ruby` and `eventmachine`
* Have a working Internet connection

## How it works

I'm going to step through it line by line, in the approximate order of execution:

[snippet: btc_transaction_firehose.rb:1,5]
