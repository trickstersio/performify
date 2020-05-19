module Performify
  module Validation
    def self.extended(base)
      base.extend Performify::Validation::ClassMethods
      base.include Performify::Validation::InstanceMethods
    end

    module ClassMethods
      def schema(outer_schema = nil, &block)
        if block_given?
          @schema = Dry::Schema.Params(**{}, &block)
        elsif outer_schema.present? && outer_schema.is_a?(Dry::Schema::Params)
          @schema = outer_schema
        else
          @schema
        end
      end
    end

    module InstanceMethods
      def schema
        self.class.schema
      end

      def validate
        return args if schema.nil?

        result = schema.call(args)

        if result.success?
          @inputs = result.output
        else
          errors!(result.errors)
        end
        result.output
      end

      def errors!(new_errors)
        raise ArgumentError, 'Errors should be a hash' if new_errors.nil? || !new_errors.respond_to?(:to_h)

        new_errors.to_h.each do |key, value|
          errors[key] = errors.key?(key) ? [errors[key]].flatten(1) + [value].flatten(1) : value
        end
      end

      def errors
        @errors ||= {}
      end

      def errors?
        errors.any?
      end
    end
  end
end
