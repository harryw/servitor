module Servitor

  class DeploymentStages

    %w(build release run).each do |attr|
      define_method(attr) do |*args|
        value = args.length > 0 ? Stage.new(*args) : nil
        attr_sym = "@#{attr}".to_sym
        instance_variable_set(attr_sym, value) unless value.nil?
        instance_variable_get(attr_sym)
      end
    end

    class Stage
      attr_reader :script, :options

      def initialize(script, options = {})
        @script = script
        @options = options
      end
    end

  end

end
