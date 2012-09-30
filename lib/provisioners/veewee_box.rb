module Servitor

  class VeeweeBox
    attr_reader :name, :os_name, :os_version

    def initialize(name, os_name, os_version, os_arch=nil)
      @name = name
      @os_name = os_name
      @os_version = os_version
      @os_arch = os_arch || '64'
    end

    def define
      veewee.cli('define', @name, template_name)
    end

    %w(undefine build destroy up halt validate export).each do |method_name|
      define_method(method_name) do
        veewee.cli(method_name, @name)
      end
    end

    class << self
      def find(name)
        definition = veewee.definitions[name]
        VeeweeBox.new(name, nil, nil) unless definition # we don't have the os name & version available
      end
    end

    private

    class << self
      def veewee
        @veewee ||= Veewee::Environment.new
      end
    end

    def template_name
      @template_name ||= begin
                           # We try to find the best match from the available templates with some educated guessing.
        os_templates = veewee.templates.select { |t| t.name =~ @os_name }
        raise UnsupportedOsRequirementError, "Unsupported OS: #{@os_name}" if os_templates.empty?

        version_templates = os_templates.select { |t| t.name =~ @os_version }
        raise UnsupportedOsRequirementError, "Unsupported OS version: #{@os_version}" if version_templates.empty?

        cpu_templates = version_templates.select { |t| t.name =~ @os_arch }
        raise UnsupportedOsRequirementError, "Unsupported OS version architecture: #{@os_arch}" if cpu_templates.empty?

        # If there are still several templates, use the one with the shortest name because it's probably the simplest.
        cpu_templates.sort_by { |t| t.name.length }.first
      end
    end
  end

  class UnsupportedOsRequirementError < StandardError; end

end
