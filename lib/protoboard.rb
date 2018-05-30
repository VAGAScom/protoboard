# frozen_string_literal: true

require 'dry-configurable'
require 'protoboard/circuit_execution'
require 'protoboard/adapters/base_adapter'
require 'protoboard/adapters/stoplight_adapter'

require 'protoboard/version'
require 'protoboard/helpers/validate_callbacks'
require 'protoboard/configuration'
require 'protoboard/circuit_breaker'
require 'protoboard/circuit'
require 'protoboard/circuit_proxy_factory'
require 'protoboard/errors/invalid_callback'

module Protoboard
  def self.config
    Protoboard::Configuration
  end

  def self.configure(&block)
    config.configure(&block)
  end
end
