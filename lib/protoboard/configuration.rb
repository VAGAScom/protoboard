# frozen_string_literal: true

module Protoboard
  class Configuration
    extend Dry::Configurable

    setting :adapter, Protoboard::Adapters::StoplightAdapter, reader: true

    setting :namespace, '', reader: true

    setting :callbacks, reader: true do
      setting :before, [], reader: true, &Protoboard::Helpers::VALIDATE_CALLBACKS

      setting :after, [], reader: true, &Protoboard::Helpers::VALIDATE_CALLBACKS
    end
  end
end
