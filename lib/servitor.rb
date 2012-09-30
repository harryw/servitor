#!/usr/bin/ruby

## Runs dependent services in a SOA

service_config = ServiceLocator.locate

graph = ServiceGraph.build(service_config)

service_configs = ServiceGraphFlattener.flatten_to_startup_order(graph)

shared_service_info = {}
service_configs.each do |service_config|
  infrastructure = InfrastructureProvisioner.provision(service_config, shared_service_info)
  AppDeployer.deploy(service_config, infrastructure, shared_service_info)
  AppBuilder.build(service_config, infrastructure, shared_service_info)
  AppReleaser.release(service_config, infrastructure, shared_service_info)
end

