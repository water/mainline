require 'active_support'
$:.unshift(File.dirname(__FILE__))
require 'factory_girl/proxy'
require 'factory_girl/proxy/build'
require 'factory_girl/proxy/create'
require 'factory_girl/proxy/attributes_for'
require 'factory_girl/proxy/stub'
require 'factory_girl/factory'
require 'factory_girl/attribute'
require 'factory_girl/attribute/static'
require 'factory_girl/attribute/dynamic'
require 'factory_girl/attribute/association'
require 'factory_girl/sequence'
require 'factory_girl/aliases'

# Shortcut for Factory.default_strategy.
#
# Example:
#   Factory(:user, :name => 'Joe')
def Factory (name, attrs = {})
  Factory.default_strategy(name, attrs)
end

if defined? Rails.configuration
  Rails.configuration.after_initialize do
    Factory.definition_file_paths = [
      File.join(Rails.root, 'test', 'factories'),
      File.join(Rails.root, 'spec', 'factories')
    ]
    Factory.find_definitions
  end
else
  Factory.find_definitions
end

