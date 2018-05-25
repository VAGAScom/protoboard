module Protoboard
  class Configuration
    extend Dry::Configurable

    setting :adapter, Protoboard::Adapters::StoplightAdapter, reader: true

    setting :namespace, '', reader: true

    setting :callbacks, reader: true do
      setting :before, [], reader: true 
      setting :after, [], reader: true
    end
  end
end

