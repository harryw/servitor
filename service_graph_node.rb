class ServiceGraphNode

  attr_reader :depends_on_nodes, :service_config

  def initialize(service_config)
    @service_config = service_config
    @depends_on_nodes = []
  end

end