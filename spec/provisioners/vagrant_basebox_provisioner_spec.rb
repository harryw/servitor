require 'spec_helper'

describe VagrantBaseboxProvisioner do

  before :each do
    @requirements = InfrastructureRequirements.new
    @requirements.os_name 'ubuntu'
    @requirements.os_version '10.04'
    @requirements.os_arch '64'
    @provisioner = VagrantBaseboxProvisioner.new(@requirements)
  end

  describe '#name' do
    @provisioner.name.should == "#{@requirements.os_name}_#{@requirements.os_version}"
  end

  describe '#provision' do

    before :all do
      @box = @provisioner.provision
    end

    it 'returns a VagrantBox' do
      @box.should be_a(VagrantBox)
    end

    describe 'the vagrant box' do

      it 'has the requested OS' do
        @box.ssh('uname -s').should =~ Regex.new(@requirements.os_name)
      end

      it 'has the requested OS version' do
        @box.ssh('uname -r').should =~ Regex.new(@requirements.os_version)
      end

      it 'has the requested OS architecture' do
        @box.ssh('uname -m').should =~ Regex.new(@requirements.os_arch)
      end

    end
  end

end