module Protoboard
  module CircuitBreaker
    module ClassMethods
      def register_circuits(circuit_methods, on_before: [], on_after: [], options:, fallback: nil)

        Protoboard::Helpers::VALIDATE_CALLBACKS.call(on_before)
        Protoboard::Helpers::VALIDATE_CALLBACKS.call(on_after)

        circuits = Protoboard::CircuitBreaker.create_circuits(
          circuit_methods,
          options.merge(
            fallback: fallback,
            on_before: on_before,
            on_after: on_after
          )
        )
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

      def create_circuits(circuit_methods, options)
        circuit_hash = case circuit_methods
                          when Array
                            circuit_methods.reduce({}) { |memo, value| memo.merge(value.to_sym => "#{formatted_namespace}#{options[:service]}\##{value}") }
                          when Hash
                            circuit_methods
                          else
                            raise ArgumentError.new('Invalid input for circuit methods')
                          end
        circuit_hash.map do |circuit_method, circuit_name|
          Circuit.new({name: circuit_name, method_name: circuit_method}.merge(options))
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
