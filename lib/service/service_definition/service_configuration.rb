module Servitor

  class ServiceConfiguration

    include HasVariables

    def resource(name, options=nil, &block)
      resource = Resource.new(name, options)
      resource.instance_exec(&block) if block_given?
      resources << resource
    end

    def resources
      @resources ||= []
    end

  end

end
