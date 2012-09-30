class ServiceGraphNode

  attr_reader :depends_on_nodes, :depended_on_by_nodes, :service_config

  def initialize(service_config)
    @service_config = service_config
    @depends_on_nodes = []
    @depended_on_by_nodes = []
  end

end