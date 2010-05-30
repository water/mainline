class ForwarderGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_active_messaging_stored_message"
      m.file 'forwarder', File.join('script', "forwarder"), { :chmod => 0755 }
    end
  end
end