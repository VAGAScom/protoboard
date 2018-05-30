module Protoboard
  class CircuitExecution
    STATES = [:pending, :success, :fail]

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
