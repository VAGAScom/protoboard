# frozen_string_literal: true

module Protoboard
  ##
  # This module is responsible to manage the circuits.
  module CircuitBreaker
    module ClassMethods
      ##
      # Registers a list of circuits to be executed
      #
      # ==== Attributes
      #
      # * +circuit_methods+ - An array of symbols representing the names of the methods to be on a circuit 
      #   or a hash containing a key with a symbol representing the name of the method and the value as the name of the circuit.
      # * +on_before+ - An array of callable objects with code to be executed before each circuit runs
      # * +on_after+ - An array of callable objects with code to be executed after each circuit runs
      # * +options+ - A hash containing the options needed for the circuit to execute
      # *   +:service+ - A string representing the name of the service for the circuit
      # *   +:open_after+ - An integer representing the number of errors to occur for the circuit to be opened
      # *   +:cool_off_after+ - An integer representing the time in seconds for the circuit to attempt to recover
      #
      #   ==== Example
      #   options: {
      #     service: 'my_cool_service',
      #     open_after: 2,
      #     cool_off_after: 3
      #   }
      #   ====
      #
      # * +fallback+ - A callable object with code to be executed as an alternative plan if the code of the circuit fails
      def register_circuits(circuit_methods, on_before: [], on_after: [], options:, fallback: nil, singleton_methods: [])
        Protoboard::Helpers::VALIDATE_CALLBACKS.call(on_before)
        Protoboard::Helpers::VALIDATE_CALLBACKS.call(on_after)

        circuits = Protoboard::CircuitBreaker.create_circuits(
          circuit_methods,
          name,
          options.merge(
            fallback: fallback,
            on_before: on_before,
            on_after: on_after
          ),
          singleton_methods
        )

        circuits.each do |circuit|
          Protoboard::CircuitBreaker.add_circuit circuit
        end

        proxy_module = Protoboard::CircuitBreaker.create_circuit_proxy(circuits, name)

        prepend proxy_module::InstanceMethods

        singleton_class.prepend proxy_module::ClassMethods
      end
    end

    class << self
      ##
      # Returns a hash with the +circuits+ names and its states.
      def services_healthcheck(with_namespace: true)
        Protoboard::Helpers::ServicesHealthcheckGenerator.new.call(with_namespace: with_namespace)
      end

      ##
      # Returns a list of registered +circuits+.
      def registered_circuits
        circuits
      end

      ##
      # Adds a +circuit+ to the list of registered +circuits+.
      def add_circuit(circuit)
        circuits << circuit
      end

      ##
      # Returns a list of +circuits+.
      def circuits
        @circuits ||= []
      end

      ##
      # Calls the module responsible for creating the proxy module that will execute the circuit.
      def create_circuit_proxy(circuits, class_name)
        CircuitProxyFactory.create_module(circuits, class_name)
      end

      ##
      # Creates a new +circuit+.
      def create_circuits(circuit_methods,class_name, options, singleton_methods)
        circuit_hash = case circuit_methods
                       when Array
                         circuit_methods.reduce({}) do |memo, value|
                           memo.merge(value.to_sym => "#{formatted_namespace}#{options[:service]}/#{class_name}\##{value}")
                         end
                       when Hash
                         circuit_methods.map { |key, value| [key, "#{formatted_namespace}#{value}"] }.to_h
                       else
                         raise ArgumentError, 'Invalid input for circuit methods'
                       end

        circuit_hash.map do |circuit_method, circuit_name|
          Circuit.new({
            name: circuit_name,
            method_name: circuit_method,
            singleton_method: singleton_methods.include?(circuit_method.to_sym)
          }
          .merge(options))
        end
      end

      def included(klass)
        klass.extend(ClassMethods)
      end

      private

      ##
      # Formats the namespace considering the configuration given when the gem starts
      def formatted_namespace
        !Protoboard.config.namespace.empty? ? "#{Protoboard.config.namespace}/" : ''
      end
    end
  end
end
