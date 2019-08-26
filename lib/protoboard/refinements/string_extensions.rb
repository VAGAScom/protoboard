module Protoboard
  module Refinements
    module StringExtensions
      refine String do
        def camelize
          string = sub(/^[a-z\d]*/) { $&.capitalize }
          string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
        end

        def convert_special_chars_to_ordinals(prefix='ORD')
          special_chars = self.scan(/\W/i)
          return self if special_chars.empty?
          
          new_string = self
          special_chars.uniq.each do |special_char|
            new_char = "#{prefix}#{special_char.ord}"
            new_string = new_string.gsub(special_char, new_char)
          end
          new_string
        end
      end
    end
  end
end
