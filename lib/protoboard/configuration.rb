# frozen_string_literal: true

module Protoboard
  class Configuration
    extend Dry::Configurable

    setting :adapter, Protoboard::Adapters::StoplightAdapter, reader: true

    setting :namespace, '', reader: true
  end
end
