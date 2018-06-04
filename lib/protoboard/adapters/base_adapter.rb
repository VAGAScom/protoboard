# frozen_string_literal: true

module Protoboard
  module Adapters
    ##
    # This class is responsible to encapsulate every action that are commom between all adapters
    class BaseAdapter
      class << self
        ##
        # Manages the execution of the code intended to run before circuit execution
        def execute_before_circuit_callbacks(circuit_execution)
          before_global_callback(circuit_execution)
          before_circuit_callback(circuit_execution)
        end

        ##
        # Manages the execution of the code intended to run after circuit execution
        def execute_after_circuit_callbacks(circuit_execution)
          after_global_callback(circuit_execution)
          after_circuit_callback(circuit_execution)
        end

        private
        ##
        # Calls the code intended to run before all circuit execution
        def before_global_callback(circuit_execution)
          Protoboard.config.callbacks.before.each do |callback|
            callback.call(circuit_execution)
          end
        end

        ##
        # Calls the code intended to run before a circuit execution
        def before_circuit_callback(circuit_execution)
          circuit_execution.circuit.on_before.each do |callback|
            callback.call(circuit_execution)
          end
        end

        ##
        # Calls the code intended to run after all circuit execution
        def after_global_callback(circuit_execution)
          Protoboard.config.callbacks.after.each do |callback|
            callback.call(circuit_execution)
          end
        end

        ##
        # Calls the code intended to run after a circuit execution
        def after_circuit_callback(circuit_execution)
          circuit_execution.circuit.on_after.each do |callback|
            callback.call(circuit_execution)
          end
        end
      end
    end
  end
end
