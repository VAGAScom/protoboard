module Protoboard
  module CircuitProxyFactory
    class << self
      def create_module(circuits, class_name)
        module_name = infer_module_name(class_name)
        proxy_module = Module.new

        Protoboard.const_set(module_name, proxy_module)
      end

      private

      def infer_module_name(class_name)
        "#{class_name}CircuitProxy"
      end
    end
  end
end
