module Servitor

  class Variable
    attr_reader :name, :options

    def initialize(name, options=nil)
      @name = name
      @options = options || {}
    end
  end

  module HasVariables
    def var(name, options=nil)
      variables << Variable.new(name, options)
    end

    def variables
      @variables ||= []
    end
  end

end
