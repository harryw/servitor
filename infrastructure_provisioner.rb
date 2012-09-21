class InfrastructureProvisioner

  class << self

    # Provisions an infrastructure that meets the given requirements.
    def provision(infrastructure_requirements)
      raise NotImplementedError
    end

  end

end