require 'stoplight'
module Protoboard
  module Adapters
    class StoplightAdapter < BaseAdapter
      class Configuration
        extend Dry::Configurable

        setting :data_store, :memory
        setting :redis_host
        setting :redis_port
      end


      def initialize
        prepare_data_store
      end

      class << self
        def configure(&block)
          Configuration.configure(&block)
        end

        def data_store; Configuration.config.data_store; end

        def redis_host; Configuration.config.redis_host; end

        def redis_port; Configuration.config.redis_port; end

        def run_circuit(circuit, &block)
          prepare_data_store

          circuit_execution = Protoboard::CircuitExecution.new(circuit)

          execute_before_circuit_callbacks(circuit_execution)

          stoplight = Stoplight(circuit.name, &block)
                        .with_threshold(circuit.open_after)
                        .with_cool_off_time(circuit.cool_off_after)

          stoplight.with_fallback &circuit.fallback if circuit.fallback
          value = stoplight.run

          circuit_execution = ::Protoboard::CircuitExecution.new(circuit, state: :success, value: value)
          execute_after_circuit_callbacks(circuit_execution)

          return value
        rescue StandardError =>  exception
          circuit_execution = Protoboard::CircuitExecution.new(circuit, state: :fail, error: exception)
          execute_after_circuit_callbacks(circuit_execution)

          raise circuit_execution.error if circuit_execution.fail?
        end

        private

        def prepare_data_store
          @data_store ||= case Configuration.config.data_store
                          when :redis
                            require 'redis'
                            redis_host = Configuration.config.redis_host
                            redis_port = Configuration.config.redis_port
                            redis = Redis.new(host: redis_host, port: redis_port)
                            data_store = Stoplight::DataStore::Redis.new(redis)
                            Stoplight::Light.default_data_store = data_store
                          else
                            Stoplight::Light.default_data_store = Stoplight::DataStore::Memory.new
                          end
        end
      end
    end
  end
end
