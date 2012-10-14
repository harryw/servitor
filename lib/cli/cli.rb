#!/usr/bin/ruby

## Runs dependent services in a SOA

module Servitor
  class CLI
    def autoconfigure

      Servitor.root = Dir.pwd

      service_config = ServiceLocator.locate

      graph = ServiceGraph.build(service_config)

      service_nodes = ServiceGraphFlattener.flatten_to_startup_order(graph)

      service_box_names = {}
      service_nodes.each do |service_node|
        service_config = service_node.service_config
        service_box_names[service_config] = InfrastructureProvisioner.provision(service_config.infrastructure_requirements)
      end
        #AppDeployer.deploy(service_config, infrastructure, shared_service_info)
        #AppBuilder.build(service_config, infrastructure, shared_service_info)
        #AppReleaser.release(service_config, infrastructure, shared_service_info)

    end

    def start

    end

    def up
      autoconfigure
      start
    end
  end
end
