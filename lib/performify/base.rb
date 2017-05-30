require 'performify/callbacks'
require 'performify/validation'

module Performify
  class Base
    extend Performify::Callbacks
    extend Performify::Validation

    attr_reader :current_user

    def initialize(current_user = nil, **args)
      @current_user = current_user

      return if args.empty?

      validate(args).each do |arg_name, arg_value|
        define_singleton_method(arg_name) { arg_value }
      end

      fail!(with_callbacks: true) if errors?
    end

    def execute!
      return if defined?(@result)

      block_result = nil

      ActiveRecord::Base.transaction do
        begin
          block_result = yield
          if block_result
            success!(with_callbacks: false)
          else
            fail!(with_callbacks: false)
          end
        rescue RuntimeError, ActiveRecord::RecordInvalid
          fail!
        end

        raise ActiveRecord::Rollback if fail?
      end

      execute_callbacks
      block_result
    end

    def execute_callbacks
      if success?
        self.class.execute_callbacks(:success, self)
      elsif fail?
        self.class.execute_callbacks(:fail, self)
      end
    end

    def success!(with_callbacks: true)
      @result = true
      execute_callbacks if with_callbacks
      @result
    end

    def fail!(with_callbacks: true, errors: nil)
      @result = false
      errors!(errors) unless errors.nil?
      execute_callbacks if with_callbacks
      @result
    end

    def success?
      @result.present?
    end

    def fail?
      @result.blank?
    end
  end
end
