module Servitor

  class ServiceConfiguration

    include HasVariables

    def resource(name, options=nil, &block)
      resource_configuration = ResourceConfiguration.new(name, options)
      resource_configuration.instance_exec(&block) if block_given?
      resources << resource_configuration
    end

    def resources
      @resources ||= []
    end

  end

end
