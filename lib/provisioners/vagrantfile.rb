require 'erubis'
module Servitor

  class Vagrantfile
    attr_reader :service_configs

    def initialize(service_configs)
      @service_configs = service_configs
    end

    def generate
    end
  end

end
