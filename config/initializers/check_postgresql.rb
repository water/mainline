unless YAML::load_file(File.join(File.dirname(File.dirname(__FILE__)), "database.yml"))["development"].values.include?("postgresql")
  abort "Support for MySQL has been removed. Take a look at issue #127 for more info".red
end