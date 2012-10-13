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

    # The result of a #provision call is that there is a base box available satisfying the specified requirements.
    # So, to test #provision we need to build a new box from that base and inspect it.

    before :all do
      @pwd = Dir.pwd
      @provisioner.provision
      @box = Servitor::VagrantBox.new('VagrantBaseBoxProvisionerTest')
      @tmpdir = File.join(@pwd, 'VagrantBaseBoxProvisionerTest')
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

    it 'has the requested OS' do
      @box.ssh('lsb_release -si', :capture => true).should =~ Regexp.new(@requirements.os_name, true)
    end

    it 'has the requested OS version' do
      @box.ssh('lsb_release -sr', :capture => true).should =~ Regexp.new(@requirements.os_version, true)
    end

    it 'has the requested OS architecture' do
      arch = case @requirements.os_arch
      when /64/
        '64'
      when /32/, /86/
        '32'
      else
        raise "unrecognized architecture: #{@requirements.os_arch}"
      end
      @box.ssh("uname -m | sed 's/x86_//;s/i[3-6]86/32/'", :capture => true).should =~ Regexp.new(arch)
    end

  end

end