module Servitor

  class InfrastructureProvisioner

    class << self

      # Provisions an infrastructure that meets the requirements for the given service config.
      # Returns an infrastructure.
      def provision(requirements)
        VagrantBox.define(requirements) do |box|
          VagrantBoxRubyInstaller.new(requirements).install(box)
        end
      end

      private

      def create_box


      end
    end

  end

end
