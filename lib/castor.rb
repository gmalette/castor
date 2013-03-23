require "castor/version"
require "castor/configuration"
require "castor/configuration/node"

module Castor
  def self.configure(&block)
    Castor::Configuration.new(block)
  end
end
