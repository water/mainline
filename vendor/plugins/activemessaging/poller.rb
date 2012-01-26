#!/usr/bin/env ruby
# Make sure stdout and stderr write out without delay for using with daemon like scripts
STDOUT.sync = true; STDOUT.flush
STDERR.sync = true; STDERR.flush

# Load Rails
Rails.root=File.expand_path(File.join(File.dirname(__FILE__), '..','..','..'))
load File.join(Rails.root, 'config', 'environment.rb')

# Load ActiveMessaging processors
ActiveMessaging::load_processors

# Start it up!
ActiveMessaging::start
