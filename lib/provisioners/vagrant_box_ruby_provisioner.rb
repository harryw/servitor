module Servitor

  class VagrantBoxRubyProvisioner < VagrantBoxProvisioner
    attr_reader :requirements

    def initialize(requirements)
      super(VagrantBaseboxProvisioner.new(requirements))
      @requirements = requirements
    end

    def name
      "#{base_provisioner.name}_ruby-#{ruby_version}"
    end

    def setup(box)
      box.execute(install_rvm_script)
      box.execute(install_ruby_script)
    end

    private

    def install_rvm_script
      <<-BASH
      curl -L https://get.rvm.io | bash -s stable --ruby
      BASH
    end

    def install_ruby_script
      <<-BASH
      rvm install #{@requirements.ruby_version}
      rvm --default use #{@requirements.ruby_version}
      BASH
    end

    def ruby_version

    end
  end

end
