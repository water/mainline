require 'rubygems'
require 'stomp'
require 'json'
require 'yaml'

print "=> Syncing Gitorious... "

Rails.env = 'production'

class Publisher
  def connect
    stomp_server, stomp_port = stomp_server_and_port
    @connection = Stomp::Connection.open(nil, nil, stomp_server, stomp_port, true)
    @connected = true
  end
  
  def stomp_server_and_port
    gitorious_yaml = YAML::load_file(File.join(File.dirname(__FILE__), "..", "..", "config", "gitorious.yml"))[Rails.env]
    server = gitorious_yaml['stomp_server_address'] || 'localhost'
    host = (gitorious_yaml['stomp_server_port'] || '61613').to_i
    return [server, host]
  end

  def post_message(message)
    connect unless @connected
    @connection.send '/queue/GitoriousPushEvent', message, {'persistent' => true}
  end
end