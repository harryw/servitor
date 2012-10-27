servitor_require 'service_graph_node'
servitor_require 'service_graph_flattener'

module Servitor

  class ServiceGraph

    attr_reader :service_nodes, :root

    def initialize
      @service_nodes = { }
    end

    # Takes a service definition and builds a graph of service definitions,
    # returning the root node for that graph
    def self.build(root_service_definition)
      new.tap { |g| g.send(:build, root_service_definition) }
    end

    private

    def build(root_service_definition)
      @root = find_or_build_node(root_service_definition)
    end

    def find_or_build_node(service_definition)
      node = @service_nodes[service_definition.name]
      return node if node
      node = ServiceGraphNode.new(service_definition)
      @service_nodes[service_definition.name] = node
      add_dependent_nodes(node)
      node
    end

    def add_dependent_nodes(node)
      node.service_definition.depends_on.each do |dependency_name|
        dependent_service_definition = ServiceLocator.locate(dependency_name)
        dependent_node = find_or_build_node(dependent_service_definition)
        node.depends_on_nodes << dependent_node if dependent_node
        dependent_node.depended_on_by_nodes << node
      end
    end

  end

end
