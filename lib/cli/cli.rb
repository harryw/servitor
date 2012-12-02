#!/usr/bin/ruby

## Runs dependent services in a SOA

module Servitor
  class CLI

    def initialize
      #Servitor.root = Dir.pwd
    end

    def autoconfigure

      SshKey.new(Servitor.ssh_dir).deploy
      vagrantfile = Vagrantfile.new(services, Servitor.ssh_dir).generate

      File.open(Servitor.vagrantfile, 'w') do |f|
        f.write(vagrantfile)
      end

        #AppDeployer.deploy(service_definition, infrastructure, shared_service_info)
        #AppBuilder.build(service_definition, infrastructure, shared_service_info)
        #AppReleaser.release(service_definition, infrastructure, shared_service_info)

    end

    def start
      main_box.up
    end

    def deploy
      configuration_provider = YamlConfigurationProvider.new(File.join(Servitor.data_root, 'variables.yml'))
      env_dir = '.envdir'
      service_nodes.each do |service_node|
        configuration_resolver = ConfigurationResolver.new(
          service_node.service_definition,
          configuration_provider,
          services)
        variables = configuration_resolver.variables

        #service = services.find {|s| s.name == service_node.service_definition.name}
        service_node.service.config_variables = variables
        EnvdirDeployer.new(main_box, service_node.service.name, service_node.service.vm_root, env_dir, variables).deploy
      end

      service_nodes.each do |service_node|
        command_prefix = EnvdirDeployer.command_prefix(service_node.service.vm_root, env_dir)
        DependencyScriptExecutor.new(main_box, service_node.service.vm_root, service_node, command_prefix, services).execute
        DeploymentStageExecutor.new(main_box, service_node.service.vm_root, service_node, command_prefix).execute
      end
    end

    def up
      autoconfigure
      start
      deploy
    end

    def halt
      main_box.halt
    end

    def destroy
      main_box.destroy
    end

    def reup
      destroy
      up
    end

    private

    def main_box
      VagrantBox.new('servitor', Servitor.data_root)
    end

    def service_nodes
      @service_nodes ||= begin
        service_definition = ServiceLocator.locate
        graph = ServiceGraph.build(service_definition)
        ServiceGraphFlattener.flatten_to_startup_order(graph)
      end
    end

    def service_box_names
      @service_box_names ||= begin
        names = {}
        service_nodes.each do |service_node|
          names[service_node] = InfrastructureProvisioner.provision(service_node.service_definition.infrastructure_requirements)
        end
        names
      end
    end

    def services
      @services ||= begin
        ServiceLinker.new(service_nodes, service_box_names).link(:first_port => 4000)
      end
    end
  end
end
