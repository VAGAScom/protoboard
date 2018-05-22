module Protoboard
  class Circuit
    attr_reader :name, :service,
                :method_name, :timeout,
                :open_after, :cool_off_after,
                :fallback

    def initialize(**options)
      @name = options.fetch(:name)
      @service = options.fetch(:service)
      @method_name = options.fetch(:method_name)
      @timeout = options.fetch(:timeout)
      @open_after = options.fetch(:open_after)
      @cool_off_after = options.fetch(:cool_off_after)
      @fallback = options[:fallback]

    rescue KeyError => e
      raise ArgumentError.new("Missing required arguments: #{e.message}")
    end
  end
end
