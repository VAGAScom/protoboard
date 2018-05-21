module Protoboard
  module CircuitBreaker
    module ClassMethods
      def register_circuits(method_names, options:)

        circuits = Protoboard::CircuitBreaker.create_circuits(method_names, options)
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
          circuit_name = "#{options[:service]}\##{method_name}"
          Circuit.new({name: circuit_name, method_name: method_name}.merge(options))
        end
      end

      def included(klass)
        klass.extend(ClassMethods)
      end
    end
  end
end
