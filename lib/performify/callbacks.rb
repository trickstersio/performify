module Performify
  module Callbacks
    class UnknownTypeOfCallbackError < StandardError; end

    TYPES_OF_CALLBACK = %i[success fail].freeze

    def clean_callbacks
      @service_callbacks = {}
    end

    def register_callback(type_of_callback, method_name = nil, &block)
      unless TYPES_OF_CALLBACK.include?(type_of_callback)
        raise UnknownTypeOfCallbackError, "Type #{type_of_callback} is not allowed"
      end
      @service_callbacks ||= {}
      @service_callbacks[type_of_callback] ||= []
      @service_callbacks[type_of_callback] << method_name if method_name
      @service_callbacks[type_of_callback] << block if block_given?
      nil
    end

    def execute_callbacks(type_of_callback, instance)
      unless TYPES_OF_CALLBACK.include?(type_of_callback)
        raise UnknownTypeOfCallbackError, "Type #{type_of_callback} is not allowed"
      end
      cbs = (@service_callbacks || {}).fetch(type_of_callback, [])
      cbs.each { |cb| instance.instance_eval(&cb) }
      nil
    end

    TYPES_OF_CALLBACK.each do |type_of_callback|
      define_method "on_#{type_of_callback}" do |method_name = nil, &block|
        register_callback(type_of_callback, method_name, &block)
      end
    end
  end
end
