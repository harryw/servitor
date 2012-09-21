class ServiceGraphBuilder

  def initialize
    @service_names = []
  end

  # takes a service config and builds a graph of service configs, returning that graph
  def self.build(root_service_config)
    new.build(root_service_config)
  end

  private

  def build(root_service_config)
    build_node(root_service_config)
  end

  def build_node(service_config)
    return nil if @service_names.include?(service_config.name)
    @service_names << service_config.name
    node = ServiceGraphNode.new(service_config)
    add_dependent_nodes(node)
    node
  end

  def add_dependent_nodes(node)
    node.service_config.depends_on.each do |dependency_name|
      dependent_service_config = ServiceLocator.locate(dependency_name)
      dependent_node = build_node(dependent_service_config)
      node.depends_on_nodes << dependent_node if dependent_node
    end
  end

end