# frozen_string_literal: true

module Protoboard
  ##
  # This module is responsible to manage a proxy module that executes the circuit.
  module CircuitProxyFactory
    class << self
      using Protoboard::Refinements::StringRefinements
      ##
      # Creates the module that executes the circuit
      def create_module(circuits, class_name)
        module_name = infer_module_name(class_name, circuits.map(&:method_name))
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

      ##
      # Formats the module name
      def infer_module_name(class_name, methods)
        "#{methods.map(&:to_s).map(&:camelize).join}#{class_name.split('::').join('')}CircuitProxy"
      end
    end
  end
end
