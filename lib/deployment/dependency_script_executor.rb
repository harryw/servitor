module Servitor
  class DependencyScriptExecutor
    def initialize(box, vm_root, service_node, services)
      @box = box
      @service_node = service_node
      @services = services
      @vm_root = vm_root
    end

    def execute
      @service_node.service_definition.configuration.dependency_scripts.each do |dependency_script|
        other_service_name = dependency_script.options[:service]
        other_service = find_service(other_service_name)
        raise DependentServiceNotFound, other_service_name unless other_service
        output = execute_service_script(other_service, dependency_script)
        update_config_from(output, dependency_script)
      end
    end

    class DependentServiceNotFound < StandardError; end
    class ScriptArgumentNotProvided < StandardError; end
    class ScriptArgumentNotFound < StandardError; end
    class ScriptDidNotReturnVariable < StandardError; end

    private

    def find_service(other_service_name)
      @services.find {|service| service.name == other_service_name}
    end

    def execute_service_script(other_service, dependency_script)
      provided_scripts = other_service.service_node.service_definition.provided_scripts
      provided_script = provided_scripts.find {|script| script.name == dependency_script.name}
      args = {}
      provided_script.arguments.each do |required_arg_name|
        provided_arg = dependency_script.arguments.find {|provided_arg| provided_arg.name == required_arg_name }
        raise ScriptArgumentNotProvided, required_arg_name unless provided_arg
        if provided_arg.options[:from] == :service_name
          provided_arg_value = @service_node.service_definition.name
        elsif (from_var = provided_arg.options[:from])
          provided_arg_value = @service_node.service.config_variables[from_var]
        else
          provided_arg_value = @service_node.service.config_variables[provided_arg.name]
        end
        raise ScriptArgumentNotFound, required_arg_name unless provided_arg_value
        args[required_arg_name] == provided_arg_value
      end

      @box.ssh(<<-BASH, :vm_name => other_service.name, :capture => true)
        cd #{@vm_root} && #{args.map {|k,v| "#{k.upcase}='#{v}'"}.join(' ')} #{provided_script.command}
      BASH
    end

    def update_config_from(output, dependency_script)
      yaml = YAML.parse(output)
      dependency_script.variables.each do |dependent_variable|
        expected_var = dependent_variable.options[:from] || dependent_variable.name
        received_var = yaml[expected_var]
        raise ScriptDidNotReturnVariable, expected_var unless received_var
        @service_node.service.config_variables[dependent_variable.name] = received_var
      end
    end
  end
end
