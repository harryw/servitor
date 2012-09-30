class VagrantBaseboxProvisioner < VagrantBoxProvisioner
  attr_reader :requirements

  def initialize(requirements)
    super
    @requirements = requirements
  end

  def name
    "#{@requirements.os_name}_#{@requirements.os_version}"
  end

  def provision
    return box if box = VagrantBox.find(name)
    create_base_box
    VagrantBox.new(name)
  end

  private

  def create_base_box
    base_box = VeeweeBox.new(name, @requirements.os_name, @requirements.os_version)
    base_box.define
    base_box.build
    base_box.validate
    base_box.halt
    base_box.export
    base_box.destroy
  end
end

