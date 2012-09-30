module Servitor

  class VagrantBoxProvisioner
    attr_reader :requirements, :base_provisioner

    def initialize(base_provisioner = nil)
      @base_provisioner = base_provisioner
    end

    # Builds a vagrant box of the configured name, to satisfy the configured requirements.
    # Returns a vagrant box.
    def provision
      return box if box = VagrantBox.find(name)
      @base_provisioner.provision.copy_to(name) do |box|
        setup(box)
      end
    end

    # Performs provisioner-specific setup steps.  Implemented in each derived provisioner.
    def setup(box)
      raise NotImplementedError, "VagrantBoxProvisioner#setup should be overridden in derived provisioners"
    end

    # Returns the name this vagrant box should have once provisioned & defined.  Implemented in each derived provisioner.
    def name
      raise NotImplementedError, "VagrantBoxProvisioner#name should be overridden in derived provisioners"
    end
  end

end