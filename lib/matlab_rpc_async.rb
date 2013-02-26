require 'em-websocket'
require 'amqp'
require 'json'
require 'uuid'
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__),'../config.yml'))
rabbitmq = config["rabbitmq"]

@sockets = []
@RPC = {}
EventMachine.run do 
  connection = AMQP.connect(:host => rabbitmq["host"], :user => rabbitmq["user"], :password => rabbitmq["password"])
  channel = AMQP::Channel.new(connection)
  exchange = channel.direct("matlab")
  reply_queue = AMQP::Queue.new(channel,"", :exclusive => true) do |q|
	q.bind(exchange,:routing_key => q.name)
  end

  reply_queue.subscribe(:ack => true) do |metadata,payload|
    corr_id = metadata.correlation_id
    if corr_id
      ws=@RPC.delete(corr_id)
      ws.send ({:code => 0,:correlation_id => corr_id, :data => JSON.parse(payload)}).to_json if ws
    end
    metadata.ack
  end

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    socket_detail = {:socket => ws}

    ws.onopen do
      @sockets << socket_detail
      puts "SOCKET INFO #{socket_detail.inspect}"
    end

    ws.onclose do
      puts "SOCKET CLOSED"
    end
   
    ws.onmessage do |msg|
      puts "Received message: #{msg}"
      begin
        request = JSON.parse(msg)
        corr_id = request["correlation_id"] || UUID.generate
	command = request["command"]
	puts command
        exchange.publish(request["command"], :routing_key => 'matlab',:reply_to => 			reply_queue.name, :correlation_id => corr_id)
      	@RPC[corr_id] = ws
      rescue JSON::ParserError => e
	puts e
        ws.send '{"code":1,"message":"Malformed JSON"}'
      end
    end
  end
end
