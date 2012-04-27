use Rack::ShowExceptions

require 'vendor/grack/lib/git_http.rb' # load from it's own submodule
require 'lib/grack/water_grack_auth.rb' # From mainline

path = File.join(File.dirname(__FILE__), "config/gitorious.yml")
gitorious_config = YAML.load_file(path)[ENV["RACK_ENV"]]

config = {
  project_root: gitorious_config["repository_base_path"],
  git_path:     "/usr/bin/git",
  upload_pack:  true,
  receive_pack: true,
}

use WaterGrackAuth

run GitHttp::App.new(config)
