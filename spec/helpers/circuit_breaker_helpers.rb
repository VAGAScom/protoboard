# frozen_string_literal: true

module CircuitBreakerHelpers
  def clean_circuits
    Protoboard::CircuitBreaker.instance_eval do
      @circuits = []
    end
  end

  def disable_constant_warnings
    $VERBOSE = nil
  end
end
