class VagrantBox
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def init(base_name)
    vagrant.cli('init', base_name)
  end

  def up
    vagrant.cli('up', '--no-provision')
  end

  def destroy
    vagrant.cli('destroy')
  end

  def package
    vagrant.cli('package', @name)
  end

  def ssh(command)
    vagrant.cli('package', '-c', command)
  end

  def provision
    vagrant.cli('provission')
  end

  def copy_to(new_name)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        new_box = VagrantBox.new(new_name)
        new_box.init(@name)
        new_box.up
        yield new_box
        new_box.package
        new_box.destroy
        return new_box
      end
    end
  end

  class << self
    def find(name)
      box = vagrant.boxes.find(name)
      VagrantBox.new(name) unless box
    end

    private

    def vagrant
      @vagrant ||= Vagrant::Environment.new
    end
  end

end