# frozen_string_literal: true

module Protoboard
  module Errors
    class InvalidCallback < StandardError
      DEFAULT_MESSAGE = 'All callbacks should respond to #call and receive one argument'
      def initialize(msg = DEFAULT_MESSAGE); end
    end
  end
end
