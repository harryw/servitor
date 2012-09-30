servitor_require 'infrastructure_provisioner'
servitor_require 'infrastructure_requirements'

module Servitor

  class Infrastructure
    attr_writer :ports
    attr_accessor :deploy_root

    def ports
      @ports || { }
    end

  end

end
