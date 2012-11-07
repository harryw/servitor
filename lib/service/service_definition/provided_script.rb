module Servitor

  class ProvidedScript
    attr_reader :name, :options, :arguments

    def initialize(name, options=nil)
      @name = name
      @options = options || {}
      @arguments = []
    end

    def command(command_line=nil)
      @command = command_line if command_line
      @command
    end

    def arg(variable_name)
      @arguments << variable_name if variable_name
    end
  end

end
