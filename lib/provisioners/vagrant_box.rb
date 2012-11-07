require 'vagrant'

module Servitor

  class VagrantBox

    include ChildProcessHelper

    class << self
      def exists?(name)
        !!self.vagrant.boxes.find(name)
      end

      def vagrant
        @vagrant ||= Vagrant::Environment.new
      end

      def add(box_name, box_file)
        execute_child_process('vagrant', 'box', 'add', box_name, box_file)
      end

      def define(requirements)
        name = box_name_for(requirements)
        return name if exists?(name)
        box = VagrantBoxProvisioner.new(requirements).provision
        yield box
        box_file = box.package
        box.destroy
        self.add(name, box_file)
        name
      end

      def box_file_for(name)
        File.join(Servitor.boxes_root, "#{name}.box")
      end

      def box_name_for(requirements)
        "servitor-#{requirements.consistent_hash.to_s(32)}"
      end
    end

    attr_reader :name, :path

    def initialize(name, path=nil)
      @name = name
      @path = path || File.join(Servitor.boxes_root, @name)
    end

    def init(base_box)
      box_dir do
        execute_child_process('vagrant', 'init', base_box)
      end
    end

    def up
      box_dir do
        execute_child_process('vagrant', 'up', '--no-provision')
      end
    end

    def halt
      box_dir do
        execute_child_process('vagrant', 'halt')
      end
    end

    def destroy
      box_dir do
        execute_child_process('vagrant', 'destroy', '--force')
      end
    end

    def package
      box_dir do
        box_file = self.class.box_file_for(@name)
        execute_child_process('vagrant', 'package', '--output', box_file)
        return box_file
      end
    end

    def ssh(command, options={})
      #puts "executing: #{command}"
      box_dir do
        sudo = options[:sudo] ? 'sudo' : ''
        shim_prefix = options[:shim_prefix] || ''
        args = ['vagrant', 'ssh', options[:vm_name], '-c',
            "#{sudo} #{shim_prefix} #{command}"].compact
        if options[:capture]
          execute_child_process_and_capture_output(*args)
        else
          execute_child_process(*args)
        end
      end
    end

    def ruby(script, options={})
      if options.delete(:sudo)
        options[:shim_prefix] = "rvmsudo #{options[:shim_prefix] || ''}"
      end
      escaped = script.
          gsub('"', {'"' => '\"'}).
          gsub('`', {'`' => '\`'})
      vm_options = {}
      vm_options[:vm_name] = options[:vm_name] if options[:vm_name]
      ssh("echo \"#{escaped}\" > /tmp/servitor-ruby", vm_options)
      ssh("ruby /tmp/servitor-ruby", options)
    end

    def provision
      box_dir do
        execute_child_process('vagrant', 'provision')
      end
    end

    private

    def box_dir(&block)
      FileUtils.mkdir_p(self.path)
      FileUtils.chdir(self.path, {}, &block)
    end

  end

end
