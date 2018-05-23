module Protoboard
  class CircuitExecution
    STATES = [:not_started, :success, :fail]

    attr_reader :circuit, :state, :value, :error
  end
end