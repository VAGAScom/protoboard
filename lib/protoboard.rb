# frozen_string_literal: true

require 'dry-configurable'
require 'protoboard/circuit_execution'
require 'protoboard/adapters/base_adapter'
require 'protoboard/adapters/stoplight_adapter'

require 'protoboard/version'
require 'protoboard/helpers/validate_callbacks'
require 'protoboard/helpers/services_healthcheck_generator'
require 'protoboard/configuration'
require 'protoboard/circuit_breaker'
require 'protoboard/circuit'
require 'protoboard/circuit_proxy_factory'
require 'protoboard/errors/invalid_callback'

##
# This module is the entry to get or set the configuration needed by the gem.
module Protoboard
  ##
  # Returns the current configuration
  def self.config
    Protoboard::Configuration
  end

  ##
  # Does the configuration needed by the gem
  def self.configure(&block)
    config.configure(&block)
  end
end
