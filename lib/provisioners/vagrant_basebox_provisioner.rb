module Servitor

  class VagrantBaseboxProvisioner < VagrantBoxProvisioner
    attr_reader :requirements

    def initialize(requirements)
      super
      @requirements = requirements
    end

    def name
      "#{@requirements.os_name}_#{@requirements.os_version}".gsub(/[^a-zA-Z0-9\-]/, '-')
    end

    def provision
      box = VagrantBox.find(name)
      return box if box
      create_base_box
      VagrantBox.new(name)
    end

    private

    def create_base_box
      base_box = VeeweeBox.new(name, @requirements.os_name, @requirements.os_version)
      base_box.define
      base_box.build(:nogui => true)
      base_box.validate
      #base_box.halt
      base_box.export
      base_box.destroy
      box_file = "#{name}.box"
      VagrantBox.add(name, box_file)
      FileUtils.rm box_file
    end
  end

end
