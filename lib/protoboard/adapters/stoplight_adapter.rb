# frozen_string_literal: true

require 'stoplight'
module Protoboard
  module Adapters
    ##
    # This class manages every aspect for the execution of a circuit using the gem stoplight
    class StoplightAdapter < BaseAdapter
      ##
      # This class represents the configuration needed to configure the gem stoplight.
      class Configuration
        extend Dry::Configurable

        setting :data_store, :memory
        setting :redis_host
        setting :redis_port
      end

      class << self
        ##
        # This methods is used to make it easier to access adapter configurations
        def configure(&block)
          Configuration.configure(&block)
        end

        ##
        # This method is used to make it easier to access adapter data store configuration
        def data_store
          Configuration.config.data_store
        end

        ##
        # This method is used to make it easier to access adapter redis host configuration
        def redis_host
          Configuration.config.redis_host
        end

        ##
        # This method is used to make it easier to access adapter redis port configuration
        def redis_port
          Configuration.config.redis_port
        end

        ##
        # Runs the circuit using stoplight
        def run_circuit(circuit, &block)
          prepare_data_store

          circuit_execution = Protoboard::CircuitExecution.new(circuit)

          execute_before_circuit_callbacks(circuit_execution)

          stoplight = Stoplight(circuit.name, &block)
                      .with_threshold(circuit.open_after)
                      .with_cool_off_time(circuit.cool_off_after)

          stoplight.with_fallback(&circuit.fallback) if circuit.fallback
          value = stoplight.run

          circuit_execution = ::Protoboard::CircuitExecution.new(circuit, state: :success, value: value)
          execute_after_circuit_callbacks(circuit_execution)

          value
        rescue StandardError =>  exception
          circuit_execution = Protoboard::CircuitExecution.new(circuit, state: :fail, error: exception)
          execute_after_circuit_callbacks(circuit_execution)

          raise circuit_execution.error if circuit_execution.fail?
        end

        # Returns the state of a circuit
        #
        # ==== States returned
        #
        # * +OK+ - when that stoplight circuit is green
        # * +NOT_OK+ - when that stoplight circuit is yellow or red
        def check_state(circuit_name)
          mapper = { 'yellow' => 'NOT_OK', 'green' => 'OK', 'red' => 'NOT_OK' }
          mapper[Stoplight(circuit_name).color]
        end

        private

        def prepare_data_store
          @prepare_data_store ||= case Configuration.config.data_store
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
