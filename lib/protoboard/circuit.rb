# frozen_string_literal: true

module Protoboard
  ##
  # This class represents a circuit.
  class Circuit
    attr_reader :name, :service,
                :method_name, :open_after,
                :cool_off_after, :on_before,
                :on_after, :fallback

    def initialize(**options)
      @name = options.fetch(:name)
      @service = options.fetch(:service)
      @method_name = options.fetch(:method_name)
      @open_after = options.fetch(:open_after)
      @cool_off_after = options.fetch(:cool_off_after)
      @fallback = options[:fallback]
      @on_before = options.fetch(:on_before, [])
      @on_after = options.fetch(:on_after, [])
      @singleton_method = options.fetch(:singleton_method, false)
    rescue KeyError => error
      raise ArgumentError, "Missing required arguments: #{error.message}"
    end

    def singleton_method?
      @singleton_method
    end
  end
end
