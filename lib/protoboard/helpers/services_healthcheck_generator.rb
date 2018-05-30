# frozen_string_literal: true

module Protoboard
  module Helpers
    class ServicesHealthcheckGenerator
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
