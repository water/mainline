use Rack::ShowExceptions

require "yaml"
require 'lib/git_http.rb'

path = File.join(File.dirname(__FILE__), "config/gitorious.yml")
gitorious_config = YAML.load_file(path)[ENV["RACK_ENV"]]

config = {
  project_root: gitorious_config["repository_base_path"],
  git_path:     "/usr/bin/git",
  upload_pack:  true,
  receive_pack: true,
}

run GitHttp::App.new(config)
