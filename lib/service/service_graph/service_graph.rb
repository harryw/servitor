servitor_require 'service_graph_node'
servitor_require 'service_graph_flattener'

module Servitor

  class ServiceGraph

    attr_reader :service_nodes, :root

    def initialize
      @service_nodes = { }
    end

    # Takes a service config and builds a graph of service configs,
    # returning the root node for that graph
    def self.build(root_service_config)
      new.tap { |g| g.send(:build, root_service_config) }
    end

    private

    def build(root_service_config)
      @root = find_or_build_node(root_service_config)
    end

    def find_or_build_node(service_config)
      return node if node = @service_nodes[service_config.name]
      node = ServiceGraphNode.new(service_config)
      @service_nodes[service_config.name] = node
      add_dependent_nodes(node)
      node
    end

    def add_dependent_nodes(node)
      node.service_config.depends_on.each do |dependency_name|
        dependent_service_config = ServiceLocator.locate(dependency_name)
        dependent_node = find_or_build_node(dependent_service_config)
        node.depends_on_nodes << dependent_node if dependent_node
        dependent_node.depended_on_by_nodes << node
      end
    end

  end

end
