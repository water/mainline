
current_dir = File.expand_path(File.dirname(__FILE__))
app_root = File.join(current_dir, "../../")

print "=> Syncing Gitorious... "
$stdout.flush
ENV["Rails.env"] ||= "production"
require File.join(app_root,"/config/environment")

