module Servitor

  class VagrantBoxProvisioner
    attr_reader :requirements

    def initialize(requirements)
      @requirements = requirements
    end

    def name
      @name ||= "#{@requirements.os_name}_#{@requirements.os_version}".gsub(/[^a-zA-Z0-9\-]/, '-')
    end

    def provision
      create_base_box unless VagrantBox.exists?(name)
      VagrantBox.new(name).tap do |box|
        box.init(name)
        box.up
      end
    end

    private

    def create_base_box
      base_box = VeeweeBox.new(name, @requirements.os_name, @requirements.os_version)
      base_box.define
      base_box.build(:nogui => true)
      base_box.validate
      base_box.export
      base_box.up
      box_file = "#{name}.box"
      VagrantBox.add(name, box_file)
      FileUtils.rm box_file
    end
  end

end
