require 'dry-configurable'
require "protoboard/adapters/stoplight_adapter"

require "protoboard/version"
require "protoboard/configuration"
require "protoboard/circuit_breaker"
require "protoboard/circuit"
require "protoboard/circuit_proxy_factory"

module Protoboard
  def self.config
    Protoboard::Configuration
  end
end
