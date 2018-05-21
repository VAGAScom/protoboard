module Protoboard
  class Configuration
    extend Dry::Configurable

    setting :adapter, Protoboard::Adapters::StoplightAdapter, reader: true


  end
end