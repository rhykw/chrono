module Chrono
  module Fields
    class Base
      class InvalidField < StandardError
        attr_reader :source

        def initialize(message, source)
          super("#{message}: #{source}")
          @source = source
        end
      end

      attr_reader :source

      def initialize(source)
        @source = source
      end

      def to_a
        if has_multiple_elements?
          fields.map(&:to_a).flatten.uniq.sort
        else
          ary = lower.step(upper, step).to_a
          if ary.empty?
            raise InvalidField.new('The range is evaluated to empty', source)
          end
          ary.sort
        end
      end

      private

      def interpolated
        source.gsub("*", "#{range.first}-#{range.last}")
      end

      def lower
        @lower ||= match_data[1].to_i
      end

      def upper
        if match_data[2]
          match_data[2].to_i
        else
          lower
        end
      end

      def step
        if match_data[3]
          match_data[3].to_i
        else
          1
        end
      end

      def pattern
        %r<\A(\d+)(?:-(\d+))?(?:/(\d+))?\z>
      end

      def match_data
        @match_data ||= interpolated.match(pattern).tap do |m|
          unless m
            raise InvalidField.new('Unparsable field', source)
          end
        end
      end

      def elements
        @elements ||= source.split(",")
      end

      def has_multiple_elements?
        elements.size >= 2
      end

      def fields
        elements.map {|element| self.class.new(element) }
      end
    end
  end
end
