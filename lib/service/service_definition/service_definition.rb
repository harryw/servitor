servitor_require 'variable'
servitor_require 'deployment_stages'
servitor_require 'resource_configuration'
servitor_require 'service_configuration'
servitor_require 'service_definition'

module Servitor

  class ServiceDefinition

    # these are part of the service configuration file
    %w(name depends_on).each do |attr|
      define_method(attr) do |*args|
        value = args.length > 0 ? args.first : nil
        attr_sym = "@#{attr}".to_sym
        instance_variable_set(attr_sym, value) unless value.nil?
        instance_variable_get(attr_sym)
      end
    end

    # these are derived at load time
    attr_reader :location, :service_root

    def initialize(location=nil, service_root=nil)
      @location = location
      @service_root = service_root
      @depends_on = []
      @deployment_stages = DeploymentStages.new
      @infrastructure_requirements = InfrastructureRequirements.new
      @configuration = ServiceConfiguration.new
    end

    def deployment_stages(*args, &block)
      @deployment_stages.instance_exec(&block) if block_given?
      @deployment_stages
    end

    def infrastructure_requirements(&block)
      @infrastructure_requirements.instance_exec(&block) if block_given?
      @infrastructure_requirements
    end

    def configuration(&block)
      @configuration.instance_exec(&block) if block_given?
      @configuration
    end
  end

end
