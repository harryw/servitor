module Servitor

  class InfrastructureProvisioner

    class << self

      # Provisions an infrastructure that meets the requirements for the given service config.
      # Returns an infrastructure.
      def provision(service_config)
        VagrantBoxProvisioner.new(service_config.name, service_config.infrastructure_requirements).provision
      end

      private

      def create_box


      end
    end

  end

end
