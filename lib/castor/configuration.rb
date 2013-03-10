require 'pry'

module Castor
  class Configuration
    def initialize(block)
      @values = {}
      instance_eval(&block)
    end

    def method_missing(name, *args, &block)
      options = args.last.is_a?(::Hash) ? args.pop : {}

      config_value = nil

      if options[:nested]
        config_value = Castor::Configuration.new(block)

        selfclass.define_method(name) do 
          config_value
        end
      else
        block = Proc.new {
          default args.first
        } unless block

        config_value = Castor::Configuration::Value.new(name, block)

        selfclass.define_method(name) do
          config_value.value
        end

        selfclass.define_method("#{name}=") do |args|
          config_value.value = args
        end
      end
      
      @values[name] = config_value
    end

    def call(attributes)
      attributes.each do |key, value|
        self.send key, value
      end
    end

    def selfclass
      class << self; self; end;
    end


    class Value
      attr_reader :value

      def initialize(name, block)
        @name = name
        instance_eval(&block)
        self.value = @default
      end

      def value=(new_value)
        if validate!(new_value)
          @value = new_value
        end
      end

      def desc(description)
        @description = description
      end

      def type(*types)
        @types = types.flatten
      end

      def value_in(*values)
        @possible_values = if values.length == 1 && values.first.is_a?(Enumerable)
          values.first
        else
          values.flatten
        end
      end

      def default(default_value)
        @default = default_value
      end

      def validate!(new_value)
        if (@possible_values && !@possible_values.include?(new_value))
          raise_validation_error(new_value, "Value must be included in #{@possible_values.to_s}")
        end

        if (@types && @types.none?{|klass| new_value.is_a?(klass)})
          raise_validation_error(new_value, "Value must be in types #{@types.to_s}")
        end

        true
      end

      def raise_validation_error(new_value, message)
        raise InvalidValueError.new("Invalid value #{new_value} for #{@name}. #{message}")
      end
    end

    class InvalidValueError < RuntimeError; end
  end
end