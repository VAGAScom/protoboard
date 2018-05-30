# frozen_string_literal: true

module Protoboard
  module Helpers
    VALIDATE_CALLBACKS = lambda do |callbacks|
      callbacks.each do |callback|
        case callback
        when Proc
          raise Errors::InvalidCallback if callback.arity != 1
        else
          raise Errors::InvalidCallback if !callback.respond_to?(:call) || callback.method(:call).arity != 1
        end
      end

      callbacks
    end
  end
end
