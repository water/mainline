require "secure_faye/server"
require "yaml"

config = YAML.load_file(File.join(File.dirname(__FILE__), "config/water.yml"))
ENV["FAYE_TOKEN"] ||= config[ENV["RACK_ENV"]]["faye"]["token"] 

Faye::WebSocket.load_adapter("thin")

run SecureFaye::Server.new.instance