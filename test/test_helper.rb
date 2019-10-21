$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV["RAILS_ENV"] = "test"

require "logger"
require "active_record"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "innkeeper"

ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

require "active_support"
require "innkeeper_test"
require "erb"

module Innkeeper
  module TestHelper
    def self.config
      @config ||= YAML.load(ERB.new(IO.read('test/databases.yml')).result)
    end
  end
end
