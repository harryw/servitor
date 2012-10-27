module Servitor

  class ResourceConfiguration
    include HasVariables

    attr_reader :name, :options

    def initialize(name, options=nil)
      @name = name
      @options = options || {}
    end
  end

end
