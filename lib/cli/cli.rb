#!/usr/bin/ruby

## Runs dependent services in a SOA

module Servitor
  class CLI
    def autoconfigure

      vagrantfile = Vagrantfile.new(services).generate

      File.open(Servitor.vagrantfile, 'w') do |f|
        f.write(vagrantfile)
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

    private

    def service_nodes
      @service_nodes ||= begin
        Servitor.root ||= Dir.pwd

        service_config = ServiceLocator.locate
        graph = ServiceGraph.build(service_config)
        ServiceGraphFlattener.flatten_to_startup_order(graph)
      end
    end

    def service_box_names
      @service_box_names ||= begin
        names = {}
        service_nodes.each do |service_node|
          names[service_node] = InfrastructureProvisioner.provision(service_node.service_config.infrastructure_requirements)
        end
        names
      end
    end

    def services
      @services ||= begin
        ServiceLinker.new(service_nodes, service_box_names).link
      end
    end

  end
end
