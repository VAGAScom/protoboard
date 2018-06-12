# frozen_string_literal: true

module Protoboard
  module Helpers
    ##
    # This class is responsible to generate information about the +circuits+ added
    class ServicesHealthcheckGenerator

      ##
      # Verifies the list of +circuits+ added and returns a hash with the +circuits names+ and its states.
      #
      #   ==== Examples
      #  {
      #    'services' => {
      #      'my_service_name' => {
      #        'circuits' => {
      #          'some_namespace/my_service_name/SomeClass#some_method' => 'OK',
      #          'my_custom_name' => 'NOT_OK'
      #        }
      #      }
      #    }
      #  }
      #  ====
      #
      def call(with_namespace:)
        circuits_hash = Protoboard::CircuitBreaker.registered_circuits.map do |circuit|
          state = Protoboard.config.adapter.check_state(circuit.name)

          { name: circuit.name, status: state, service: circuit.service }
        end
        services_hash = circuits_hash
                        .group_by { |circuit| circuit[:service] }
                        .map do |service, circuits_hash|

          circuits = circuits_hash.each_with_object({}) do |circuit, memo|
            circuit_name = format_circuit_name(circuit[:name], with_namespace: with_namespace)
            memo[circuit_name] = circuit[:status]
          end
          { service => { 'circuits' => circuits } }
        end.reduce(:merge)

        { 'services' => services_hash.to_h }
      end

      private

      def format_circuit_name(circuit_name, with_namespace:)
        return circuit_name if with_namespace

        circuit_name.sub("#{Protoboard.config.namespace}/", '')
      end
    end
  end
end
