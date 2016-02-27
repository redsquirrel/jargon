require 'rubygems'
require 'bitcoin'
require 'eventmachine'
require 'resolv'
require 'set'

module BitcoinTransactionReader
  def initialize(ip_address, database)
    @ip_address = ip_address
    @database = database
    @parser = Bitcoin::Protocol::Parser.new(self)
  end

  # begin EventMachine methods
  def post_init
    version = Bitcoin::Protocol::Version.new(
      from:       "127.0.0.1:8333",
      to:         @ip_address,
      user_agent: MY_USER_AGENT_STRING,
    )
    send_data(version.to_pkt)
  end
  
  def receive_data(data)
    @parser.parse(data)
  end
  # end EventMachine methods

  # begin Parser methods
  def on_version(version)
    puts "Handshake completed with: #{version.inspect}"
  end

  def on_ping(nonce)
    send_data(Bitcoin::Protocol.pong_pkt(nonce))
  end

  def on_inv_transaction(hash)
    send_data(Bitcoin::Protocol.getdata_pkt(:tx, [hash]))
  end

  def on_inv_block_v2(hash, idx, count)
    # I'm just here so I don't get fined.
  end

  def on_tx(tx)
    @database.inbound_transaction(tx)
  end
  # end Parser methods
end

class BitcoinTransactionDatabase
  def initialize
    @trasaction_hashes = Set.new
  end

  def inbound_transaction(tx)
    return if @trasaction_hashes.include?(tx.hash)
    @trasaction_hashes.add(tx.hash)

    total_out = tx.out.inject(0) { |total, out| total + out.value }
    puts tx.hash + " amount: " + total_out.to_s
  end
end

MY_USER_AGENT_STRING = put_something_here

seed = Bitcoin.network[:dns_seeds].sample
puts "Grabbing addresses based on seed: " + seed
addresses = Resolv::DNS.new.getresources(seed, Resolv::DNS::Resource::IN::A).map {|r|r.address.to_s}
database = BitcoinTransactionDatabase.new

EventMachine.run do
  addresses.each do |address|
    puts "Attempting to connect to " + address
    EventMachine.connect(address, 8333, BitcoinTransactionReader, address, database)
  end
end