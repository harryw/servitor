module Servitor

  class ServiceGraphNode

    attr_reader :depends_on_nodes, :depended_on_by_nodes, :service_definition

    attr_accessor :service

    def initialize(service_definition)
      @service_definition = service_definition
      @depends_on_nodes = []
      @depended_on_by_nodes = []
    end

  end

end
