module Protoboard
  class Configuration
    extend Dry::Configurable

    VALIDATE_CALLBACKS = lambda do |callbacks|
      callbacks.each do |callback|
        case callback
        when Proc
          raise Errors::InvalidCallback if callback.arity != 1
        else
          raise Errors::InvalidCallback if callback.method(:call).arity != 1
        end
      end

      callbacks
    end

    setting :adapter, Protoboard::Adapters::StoplightAdapter, reader: true

    setting :namespace, '', reader: true

    setting :callbacks, reader: true do
      setting :before, [], reader: true, &VALIDATE_CALLBACKS

      setting :after, [], reader: true, &VALIDATE_CALLBACKS
    end
  end
end

