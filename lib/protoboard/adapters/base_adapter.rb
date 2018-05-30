module Protoboard
  module Adapters
    class BaseAdapter
      class << self
        def execute_before_circuit_callbacks(circuit_execution)
          before_global_callback(circuit_execution)
          before_circuit_callback(circuit_execution)
        end

        def execute_after_circuit_callbacks(circuit_execution)
          after_global_callback(circuit_execution)
          after_circuit_callback(circuit_execution)
        end

        private

        def before_global_callback(circuit_execution)
          Protoboard.config.callbacks.before.each do |callback|
            callback.call(circuit_execution)
          end
        end

        def before_circuit_callback(circuit_execution)
          circuit_execution.circuit.on_before.each do |callback|
            callback.call(circuit_execution)
          end
        end

        def after_global_callback(circuit_execution)
          Protoboard.config.callbacks.after.each do |callback|
            callback.call(circuit_execution)
          end
        end

        def after_circuit_callback(circuit_execution)
          circuit_execution.circuit.on_after.each do |callback|
            callback.call(circuit_execution)
          end
        end
      end
    end
  end
end
