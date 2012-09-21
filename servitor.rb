#!/usr/bin/ruby

## Runs dependent services in a SOA

service_config = ServiceLocator.locate

graph = ServiceGraph.build(service_config)

service_configs = ServiceGraphFlattener.flatten_to_startup_order(graph)

service_configs.each do |service_config|
  infrastructure = InfrastructureProvisioner.provision(service_config.infrastructure_requirements)
end

