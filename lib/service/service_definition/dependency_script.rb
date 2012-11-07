module Servitor

  class DependencyScript
    include HasVariables

    attr_reader :name, :options

    def initialize(name, options=nil)
      @name = name
      @options = options || {}
    end

    def arg(name, options=nil)
      arguments << Argument.new(name, options)
    end

    def arguments
      @arguments ||= []
    end

    class Argument
      attr_reader :name, :options

      def initialize(name, options=nil)
        @name = name
        @options = options || {}
      end
    end
  end

end
