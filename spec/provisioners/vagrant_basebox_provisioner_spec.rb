require 'spec_helper'

describe Servitor::VagrantBaseboxProvisioner do

  before :all do
    @requirements = Servitor::InfrastructureRequirements.new
    @requirements.os_name 'ubuntu'
    @requirements.os_version '10.04'
    @requirements.os_arch '64'
    @provisioner = Servitor::VagrantBaseboxProvisioner.new(@requirements)
  end

  describe '#name' do
    it 'contains the os name and version' do
      @provisioner.name.should == "#{@requirements.os_name}-#{@requirements.os_version}".gsub(/[^a-zA-Z0-9\-]/, '-')
    end
  end

  describe '#provision' do

    before :all do
      @pwd = Dir.pwd
      @basebox = @provisioner.provision
      @box = Servitor::VagrantBox.new('VagrantBaseBoxProvisionerTest')
      @tmpdir = File.join(@pwd, '.servitortest', 'VagrantBaseBoxProvisionerTest')
      FileUtils.mkdir_p @tmpdir
      FileUtils.cd @tmpdir
      @box.init(@basebox.name)
      @box.up
    end

    after :all do
      @box.destroy
      FileUtils.cd @pwd
      FileUtils.rm_rf @tmpdir
    end

    it 'has the requested OS' do
      @box.ssh('uname -s').should =~ Regexp.new(@requirements.os_name)
    end

    it 'has the requested OS version' do
      @box.ssh('uname -r').should =~ Regexp.new(@requirements.os_version)
    end

    it 'has the requested OS architecture' do
      @box.ssh('uname -m').should =~ Regexp.new(@requirements.os_arch)
    end

  end

end