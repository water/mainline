# Load the rails application
require File.expand_path('../application', __FILE__)

APP_CONFIG = YAML::load_file(File.join(Rails.root,"config/water.yml"))[Rails.env]

# Initialize the rails application
Gitorious::Application.initialize!