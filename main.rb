require_relative 'client/client.rb'
require_relative './ruby_bot.rb'

# Client.new(RubyBot, ARGV[0], ARGV[1]).run
Client.new(RubyBot, '127.0.0.1', 15000).run