class VagrantBoxServiceProvisioner < VagrantBoxProvisioner
  attr_reader :name, :requirements

  def initialize(name, requirements)
    super(VagrantBoxChefProvisioner.new(requirements))
    @name = name
    @requirements = requirements
  end

  # Modifies the given, running box to satisfy the configured requirements.
  def setup(box)
  end
end