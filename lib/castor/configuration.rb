require 'pry'

module Castor
  class Configuration
    include Enumerable

    def initialize(block)
      @values = {}
      instance_eval(&block)
      @initialized = true
    end

    def def(name, *args, &block)
      return super(name, *args, block) if @initialized

      options = args.last.is_a?(::Hash) ? args.pop : {}
      config_value = nil

      if options[:nested]
        config_value = Castor::Configuration.new(block)

        selfclass.define_method(name) do 
          config_value
        end
      else
        block = Proc.new {
          default (args.first || options.delete(:lazy))
        } unless block

        config_value = Castor::Configuration::Node.new(name, block)

        selfclass.define_method(name) do
          config_value.value
        end

        selfclass.define_method("#{name}=") do |args|
          config_value.value = args
        end

        selfclass.define_method("#{name}!") do
          config_value
        end
      end
      
      @values[name] = config_value
    end

    def def_many(attributes)
      attributes.each do |key, value|
        self.def key, value
      end
    end

    def selfclass
      class << self; self; end;
    end

    def each(&block)
      @values.each(&block)
    end

    def merge(hash)
      hash.each do |k, v|
        if self.send(k).is_a?(Castor::Configuration)
          self.send(k).merge(v)
        else
          self.send("#{k}=", v)
        end
      end
    end

    class InvalidValueError < RuntimeError; end
  end
end