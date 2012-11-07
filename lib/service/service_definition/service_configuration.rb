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

    def dependency_script(name, options=nil, &block)
      script = DependencyScript.new(name, options)
      script.instance_exec(&block) if block_given?
      dependency_scripts << script
    end

    def dependency_scripts
      @dependency_scripts ||= []
    end
  end

end
