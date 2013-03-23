module Castor
  class Configuration
    class Node
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

      def value
        lazy? ? lazy_value : @value
      end

      private 

      def lazy_value
        v = @value.call
        validate!(v, true)
        v
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

      def default(default_value = nil, &block)
        @default = default_value || block
      end

      def lazy?(lazy_value = nil)
        lazy_value = lazy_value || @value || @default
        lazy_value.is_a?(Proc) && !(@types && @types.include?(Proc))
      end

      def validate!(new_value, jit = false)
        return true if lazy?(new_value) && !jit

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
  end
end