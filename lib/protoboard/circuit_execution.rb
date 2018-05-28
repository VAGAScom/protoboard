# frozen_string_literal: true

module Protoboard
  class CircuitExecution
    STATES = %i[not_started success fail].freeze

    attr_reader :circuit, :state, :value, :error
  end
end
