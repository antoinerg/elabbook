require 'bunny'

class ElasticSearch
  def initialize
    @conn = Bunny.new(:host => "elabbook.lxc", :user => "elasticsearch", :password => "elasticsearch")
    @conn.start
    @channel = @conn.create_channel
    @exchange = @channel.default_exchange
  end
  
  def stop
    @conn.stop
  end
  
  def publish(msg)
    @exchange.publish(msg,:routing_key => 'elasticsearch')
  end
end