require 'veewee'

module Servitor

  class VeeweeBox

    include ChildProcessHelper

    class << self
      def find(name)
        definition = self.veewee.definitions[name]
        VeeweeBox.new(name, nil, nil) if definition # we don't have the os name & version available
      end

      def veewee
        @veewee ||= Veewee::Environment.new
      end

      def vagrant
        VagrantBox.vagrant
      end
    end

    attr_reader :name, :os_name, :os_version

    def initialize(name, os_name, os_version, os_arch=nil)
      raise InvalidNameError, name unless name =~ /^[a-zA-Z0-9\-]+$/
      @name = name
      @os_name = os_name
      @os_version = os_version
      @os_arch = os_arch || '64'
    end

    def define
      execute_child_process('vagrant', 'basebox', 'define', @name, template_name)
    end

    def build(options={})
      build_args = ['vagrant', 'basebox', 'build', @name, '--auto']
      build_args << '--nogui' if options[:nogui]
      execute_child_process(*build_args)
    end

    %w(up destroy).each do |method_name|
      define_method(method_name) do
        begin
          execute_child_process('vagrant', 'basebox', method_name, @name)
        rescue StandardError => e
          raise e, "#{method_name}: #{e.message}", e.backtrace
        end
      end
    end

    %w(undefine validate export halt).each do |method_name|
      define_method(method_name) do
        begin
          execute_child_process('vagrant', 'basebox', method_name, @name)
        rescue StandardError => e
          raise e, "#{method_name}: #{e.message}", e.backtrace
        end
      end
    end

    private

    def template_name
      @template_name ||= begin
        # We try to find the best match from the available templates with some educated guessing.
        os_templates = []
        self.class.veewee.templates.each do |name, template|
          os_templates << template if name =~ Regexp.new(@os_name)
        end
        raise UnsupportedOsRequirementError, "Unsupported OS: #{@os_name}" if os_templates.empty?

        version_templates = os_templates.select { |t| t.name =~ Regexp.new(@os_version) }
        raise UnsupportedOsRequirementError, "Unsupported OS version: #{@os_version}" if version_templates.empty?

        cpu_templates = version_templates.select { |t| t.name =~ Regexp.new(@os_arch) }
        raise UnsupportedOsRequirementError, "Unsupported OS version architecture: #{@os_arch}" if cpu_templates.empty?

        # If there are still several templates, use the one with the shortest name because it's probably the simplest.
        template = cpu_templates.map(&:name).sort_by(&:length).first
      end
    end
  end

  class UnsupportedOsRequirementError < StandardError; end
  class InvalidNameError < StandardError; end
  class VagrantBaseBoxError < StandardError; end

end
