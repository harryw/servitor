require 'vagrant'
servitor_require 'child_process_helper'

module Servitor

  class VagrantBox

    include ChildProcessHelper

    class << self
      def find(name)
        box = self.vagrant.boxes.find(name)
        VagrantBox.new(name) if box
      end

      def vagrant
        @vagrant ||= Vagrant::Environment.new
      end

      def add(box_name, box_file)
        execute_child_process('vagrant', 'box', 'add', box_name, box_file)
      end
    end

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def init(base_name)
      execute_child_process('vagrant', 'init', base_name)
    end

    def up
      execute_child_process('vagrant', 'up', '--no-provision')
    end

    def destroy
      execute_child_process('vagrant', 'destroy', '--force')
    end

    def package_and_add
      box_file = "#{@name}.box"
      execute_child_process('vagrant', 'package', '--output', box_file)
      self.class.add(@name, box_file)
      FileUtils.rm box_file
    end

    def ssh(command, options={})
      args = ['vagrant', 'ssh', '-c', command]
      if options[:capture]
        execute_child_process_and_capture_output(*args)
      else
        execute_child_process(*args)
      end
    end

    def provision
      execute_child_process('vagrant', 'provision')
    end

    def copy_to(new_name)
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          new_box = VagrantBox.new(new_name)
          new_box.init(@name)
          new_box.up
          yield new_box
          new_box.package_and_add
          new_box.destroy
          return new_box
        end
      end
    end

  end

end
