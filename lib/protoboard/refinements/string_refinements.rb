module Protoboard
  module Refinements
    module StringRefinements
      refine String do
        def camelize
          string = sub(/^[a-z\d]*/) { $&.capitalize }
          string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
        end
      end
    end
  end
end
