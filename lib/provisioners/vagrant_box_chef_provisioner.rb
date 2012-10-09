module Servitor

  class VagrantBoxChefProvisioner < VagrantBoxProvisioner
    attr_reader :requirements

    def initialize(requirements)
      super(VagrantBoxRubyProvisioner.new(requirements))
      @requirements = requirements
    end

    def name
      "#{base_provisioner.name}_chef-#{chef_requirements_hash}"
    end

    def setup(box)
      box.execute(clone_chef_repo_script)
      File.open('Vagrantfile', 'w') do |f|
        f.write(vagrantfile)
      end
      box.provision
    end

    private

    REPO_PATH = '.servitor_data/chef-repo'

    def vagrantfile
      <<-RUBY
        Vagrant::Config.run do |config|
          config.vm.box = #{base_provisioner.name.inspect}

          config.vm.provision :chef_solo do |chef|
            chef.cookbooks_path = "#{REPO_PATH}/cookbooks"
            chef.roles_path = "#{REPO_PATH}/roles"
            chef.data_bags_path = "#{REPO_PATH}/data_bags"
            chef.run_list = #{@requirements.chef_runlist.inspect}

            chef.add_recipe "mysql"
            chef.add_role "web"

            # You may also specify custom JSON attributes:
            chef.json = #{@requirements.chef_attributes}.inspect
          end
        end
      RUBY
    end

    def clone_chef_repo_script
      <<-BASH
        mkdir -p #{REPO_PATH}
        git clone #{@requirements.chef_repo} #{REPO_PATH} -b #{@requirements.chef_repo_ref} -d 1
      BASH
    end

    def chef_requirements_hash
      @requirements.hash.to_s(36)
    end
  end

end
