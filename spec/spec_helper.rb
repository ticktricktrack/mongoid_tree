$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "mongoid"

require 'mongoid_tree'
require 'rspec'
require 'rspec/autorun'

Mongoid.configure do |config|
  name = "mongoid_tree_test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  # config.slaves = [
    # Mongo::Connection.new(host, 27018, :slave_ok => true).db(name)
  # ]
end

# I have never got the hang of including files, probably because the Syntax is so horrible.
# This is the easiest I could come up with.
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }


RSpec.configure do |config|
    #--format nested
    #--color
end
