# frozen_string_literal: true

module Protoboard
  class Circuit
    attr_reader :name, :service,
                :method_name, :timeout,
                :open_after, :cool_off_after,
                :on_before, :on_after,
                :fallback

    def initialize(**options)
      @name = options.fetch(:name)
      @service = options.fetch(:service)
      @method_name = options.fetch(:method_name)
      @timeout = options.fetch(:timeout)
      @open_after = options.fetch(:open_after)
      @cool_off_after = options.fetch(:cool_off_after)
      @fallback = options[:fallback]
      @on_before = options.fetch(:on_before, [])
      @on_after = options.fetch(:on_after, [])
    rescue KeyError => e
      raise ArgumentError, "Missing required arguments: #{e.message}"
    end
  end
end
