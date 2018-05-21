require 'stoplight'
require 'byebug'

module Protoboard
  module Adapters
    class StoplightAdapter
      class Configuration
        extend Dry::Configurable

        setting :data_store, ::Stoplight::DataStore::Memory.new
        
        setting :redis_host

        setting :redit_port
      end

      def initialize
        prepare_data_store
      end

      class << self
        def run_circuit(circuit, &block)
            prepare_data_store

            Stoplight(circuit.name, &block)
              .with_threshold(circuit.open_after)
              .with_cool_off_time(circuit.cool_off_after)
              .run
        end

        private
        def prepare_data_store
          @data_store ||= case Configuration.config.data_store
          when Stoplight::DataStore::Redis
            require 'redis'
            redis_host = Configuration.config.redis_host
            redis_port = Configuration.config.redis_port
            redis = Redis.new(host: redis_host, port: redis_port)
            data_store = Stoplight::DataStore::Redis.new(redis)
            Stoplight::Light.default_data_store = data_store
          else
            Stoplight::Light.default_data_store = Configuration.config.data_store
          end
        end
      end
    end
  end
end