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
      #   'services' => {
      #    'my_service_name' => {
      #       'circuits' => {
      #         'my_service_name#some_method' => 'OK',
      #         'my_custom_name' => 'NOT_OK'
      #       }
      #     }
      #   }
      #  ====
      #
      def call
        circuits_hash = Protoboard::CircuitBreaker.registered_circuits.map do |circuit|
          state = Protoboard.config.adapter.check_state(circuit.name)

          { name: circuit.name, status: state, service: circuit.service }
        end
        services_hash = circuits_hash
                        .group_by { |circuit| circuit[:service] }
                        .map do |service, circuits_hash|
          circuits = circuits_hash.each_with_object({}) { |circuit, memo| memo[circuit[:name]] = circuit[:status] }
          { service => { 'circuits' => circuits } }
        end.reduce(:merge)

        { 'services' => services_hash }
      end
    end
  end
end
