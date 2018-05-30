# frozen_string_literal: true

module Protoboard
  module CircuitProxyFactory
    class << self
      def create_module(circuits, class_name)
        module_name = infer_module_name(class_name)
        proxy_module = Module.new

        proxy_module.instance_exec do
          circuits.each do |circuit|
            define_method(circuit.method_name) do |*args|
              Protoboard.config.adapter.run_circuit(circuit) { super(*args) }
            end
          end
        end

        Protoboard.const_set(module_name, proxy_module)
      end

      private

      def infer_module_name(class_name)
        "#{class_name.split('::').join('')}CircuitProxy"
      end
    end
  end
end
