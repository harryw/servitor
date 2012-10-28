module Servitor

  class ConfigurationResolver
    def initialize(service_definition, configuration_provider, services)
      @service_definition = service_definition
      @configuration_provider = configuration_provider
      @services = services
    end

    def variables
      @variables ||= begin
        vars = resolve_variables(service_configuration.variables)
        service_configuration.resources.each do |resource_configuration|
          vars.merge!(resolve_resource_variables(resource_configuration)) do |key, _, _|
            raise VariableConflict, "'#{key}' is defined more than once"
          end
        end
        vars
      end
    end

    class VariableConflict < StandardError; end
    class DependentServiceNotFound < StandardError; end
    class MissingRequiredVariable < StandardError; end
    class ResourceNotFound < StandardError; end

    private

    def service_configuration
      @service_definition.configuration
    end

    def provided_variables
      @provided_variables ||= @configuration_provider.variables_for(@service_definition.name)
    end

    def resolve_variables(required_variables)
      resolved_variables = {}
      required_variables.map do |required_variable|
        value = nil
        if (service_name = required_variable.options[:domain_for])
          service = @services.find{|s| s.name == service_name}
          raise DependentServiceNotFound, service_name unless service
          value = service.ip_address
        else
          value = provided_variables[required_variable.name]
        end

        if value.nil?
          if (default = required_variable.options[:default])
            value = default
          else
            raise MissingRequiredVariable, required_variable.name
          end
        end

        if (format = required_variable.options[:format])
          value = Erubis::Eruby.new(format).result(:value => value)
        end
        resolved_variables[required_variable.name] = value
      end
      resolved_variables
    end

    def resolve_resource_variables(resource_configuration)
      resolved_variables = {}
      resource = resources[resource_configuration.name]
      raise ResourceNotFound, resource_configuration.name unless resource
      resource_configuration.variables.each do |required_variable|
        source_attribute = required_variable.options[:from]
        raise ResourceAttributeNotFound, source_attribute unless resource.key?(source_attribute)
        resolved_variables[required_variable.name] = resource[source_attribute]
      end
      resolved_variables
    end

    def resources
      @resources ||= @configuration_provider.resources_for(@service_definition.name)
    end
  end

end
