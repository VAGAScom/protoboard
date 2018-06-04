# frozen_string_literal: true

module Protoboard
  ##
  # This class represents a circuit execution.
  class CircuitExecution
    STATES = %i[not_started success fail].freeze

    attr_reader :circuit, :state, :value, :error

    def initialize(circuit, state: :pending, value: nil, error: nil)
      @circuit = circuit
      @state = state
      @value = value
      @error = error
    end

    def fail?
      @state == :fail
    end
  end
end
