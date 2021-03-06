# frozen_string_literal: true

module Protoboard
  ##
  # This module is responsible to manage a proxy module that executes the circuit.
  module CircuitProxyFactory
    class << self
      using Protoboard::Refinements::StringExtensions
      ##
      # Creates the module that executes the circuit
      def create_module(circuits, class_name)
        module_name = infer_module_name(class_name, circuits.map(&:method_name))
        proxy_module = Module.new

        # Encapsulates instance methods in a module to be used later
        instance_methods = Module.new do
          circuits.each do |circuit|
            unless circuit.singleton_method?
              define_method(circuit.method_name) do |*args|
                Protoboard.config.adapter.run_circuit(circuit) { super(*args) }
              end
            end
          end
        end

        proxy_module.const_set('InstanceMethods', instance_methods)

        # Encapsulates singleton methods in a module to be used later
        class_methods = Module.new do
          circuits.each do |circuit|
            if circuit.singleton_method?
              define_method(circuit.method_name) do |*args|
                Protoboard.config.adapter.run_circuit(circuit) { super(*args) }
              end
            end
          end
        end

        proxy_module.const_set('ClassMethods', class_methods)

        Protoboard.const_set(module_name, proxy_module)
      end

      private

      ##
      # Formats the module name
      def infer_module_name(class_name, methods)
        methods = methods.map(&:to_s).map do |method|
          method.convert_special_chars_to_ordinals
        end
        methods_joined = methods.map { |method| method.camelize }.join
        "#{methods_joined}#{class_name.split('::').join('')}CircuitProxy"
      end
    end
  end
end
