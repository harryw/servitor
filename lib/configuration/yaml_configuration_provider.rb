module Servitor

  class YamlConfigurationProvider

    def initialize(file_path)
      @file_path = file_path
    end

    def variables_for(service_name)
      services = yaml['services']
      service_vars = services[service_name] || {}
      common_vars = services['common'] || {}
      common_vars.merge(service_vars)
    end

    def resources_for(service_name)
      resources = yaml['resources']
      resources[service_name] || {}
    end

    private

    def yaml
      @yaml ||= YAML.load_file(@file_path)
    end
  end

end
