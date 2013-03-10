require "castor/version"
require "castor/configuration"

module Castor
  def self.configure(&block)
    Castor::Configuration.new(block)
  end
end
