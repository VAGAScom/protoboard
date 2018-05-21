module CircuitBreakerHelpers
  def clean_circuits
    Protoboard::CircuitBreaker.instance_eval do
      @circuits = []
    end
  end
end
