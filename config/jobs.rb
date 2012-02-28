require File.expand_path("../environment", __FILE__)

job "do-nothing" do |args|
  p args
end