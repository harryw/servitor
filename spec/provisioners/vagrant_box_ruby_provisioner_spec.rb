require 'spec_helper'

describe Servitor::VagrantBoxRubyProvisioner do

  before :all do
    @requirements = Servitor::InfrastructureRequirements.new
    @requirements.os_name 'ubuntu'
    @requirements.os_version '10.04'
    @requirements.os_arch '64'
    @requirements.ruby_version '1.9.2'
    @provisioner = Servitor::VagrantBoxRubyProvisioner.new(@requirements)
  end

  describe '#name' do
    it 'contains the ruby version' do
      @provisioner.name.should == "#{@requirements.os_name}-#{@requirements.os_version}-ruby-#{@requirements.ruby_version}".gsub(/[^a-zA-Z0-9\-]/, '-')
    end
  end

  describe '#provision' do

    # The result of a #provision call is that there is a base box available satisfying the specified requirements.
    # So, to test #provision we need to build a new box from that base and inspect it.

    before :all do
      @pwd = Dir.pwd
      @provisioner.provision
      @box = Servitor::VagrantBox.new('VagrantBoxRubyProvisionerTest')
      @tmpdir = File.join(@pwd, 'VagrantBoxRubyProvisionerTest')
      FileUtils.mkdir_p @tmpdir
      FileUtils.cd @tmpdir
      @box.init(@provisioner.name)
      @box.up
    end

    after :all do
      @box.destroy
      FileUtils.cd @pwd
      FileUtils.rm_rf @tmpdir
    end

    it 'uses the requested ruby version' do
      @box.ssh('ruby --version', :capture => true).should =~ Regexp.new(@requirements.ruby_version, true)
    end

  end

end