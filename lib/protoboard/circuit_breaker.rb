module Protoboard
  module CircuitBreaker
    module ClassMethods
      def register_circuits(circuit_methods, options:, fallback: nil)
        method_names = case circuit_methods
        when Array
          circuit_methods
        when Hash
          circuit_methods.keys.map(&:to_sym)
        else
          raise ArgumentError.new('Invalid input for circuit_methods')
        end

        circuits = Protoboard::CircuitBreaker.create_circuits(circuit_methods, options.merge(fallback: fallback))
        circuits.each do |circuit|
          Protoboard::CircuitBreaker.add_circuit circuit
        end

        proxy_module = Protoboard::CircuitBreaker.create_circuit_proxy(circuits, self.name)
        self.prepend proxy_module
      end
    end

    class << self
      def registered_circuits
        circuits
      end

      def add_circuit(circuit)
        circuits << circuit
      end

      def circuits
        @circuits ||= []
      end

      def create_circuit_proxy(circuits, class_name)
        CircuitProxyFactory.create_module(circuits, class_name)
      end

      def create_circuits(method_names, options)
        method_names.map do |method_name|
          circuit_name = "#{formatted_namespace}#{options[:service]}\##{method_name}"
          Circuit.new({name: circuit_name, method_name: method_name}.merge(options))
        end
      end

      def included(klass)
        klass.extend(ClassMethods)
      end

      private

      def formatted_namespace
        Protoboard.config.namespace.size > 0 ?  "#{Protoboard.config.namespace}/" : ''
      end
    end
  end
end
