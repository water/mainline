namespace :activemessaging do
  desc "Finds stored messages and delivers them to their original destination"
  task :forward => :environment do
    $:.unshift File.dirname(__FILE__) + '/../lib/'
    require 'activemessaging/gateway'
    require 'activemessaging/forwarder'
    
    puts "Running forwarder"
    ActiveMessaging::Forwarder.run
  end
end