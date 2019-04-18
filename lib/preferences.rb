
require 'preferences/preference'
require 'preferences/configuration'
require 'preferences/base'
require 'preferences/scopes'

ActiveRecord::Base.class_eval do
  def self.has_preferences(*args, &block)
    Preferences::Configuration.new(*args.unshift(self), &block)
    
    include Preferences::Base
    extend Preferences::Scopes
  end
end

