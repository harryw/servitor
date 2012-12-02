require 'yaml'

module Servitor
  class Executioner
    def initialize(stage, box, service_node, command_prefix)
      @stage = stage
      @box = box
      @service_node = service_node
      @command_prefix = command_prefix
    end

    def execute
      raise InvalidExecutionStageError, 'Only shell commands are allowed' if @stage.options[:language] && stage.options[:language] != :shell

      if @stage.options[:daemonized]
        return execute_daemonized
      end

      options = {}
      options[:vm_name] = @service_node.service.name
      if @stage.script == :procfile
        commands = YAML.load_file(File.join(@service_node.service.root, 'Procfile'))
      else
        commands = {'app' => @stage.script}
      end
      commands.keys.each do |process_name|
        command = commands[process_name]
        command = `PORT=8080 /bin/bash -c 'echo "#{command}"'`.chomp
        commands[process_name] = "#{@command_prefix} #{command}"
      end

      bluepill_config_erb = <<-RUBY
        Bluepill.application('servitorapp', :log_file => "/var/log/bluepill.log") do |app|
          app.working_dir = <%= @service_node.service.vm_root.inspect %>
          app.uid = "vagrant"
          app.gid = "vagrant"
          <% @commands.each do |process_name, command| %>
            app.process(<%= process_name.inspect %>) do |process|
              process.start_command = <%= command.inspect %>
              process.pid_file = "/tmp/servitorapp-<%= process_name %>.pid"
              process.daemonize = <%= @daemonize.inspect %>
            end
          <% end %>
        end
      RUBY

      eruby = Erubis::Eruby.new(bluepill_config_erb)
      context = Erubis::Context.new(
          :service_node => @service_node,
          :commands => commands)
      bluepill_config = eruby.evaluate(context)
      pill_file = File.join(@service_node.service.vm_root, 'servitorapp.pill')
      @box.put(bluepill_config, pill_file, options.merge(:sudo => true))

      script = <<-BASH
        rvmsudo gem install bluepill
        rvmsudo bluepill load #{pill_file.inspect}
        rvmsudo bluepill restart servitorapp
      BASH
      @box.ssh(script, options)
    end

    class InvalidExecutionStageError < StandardError; end

    private

    def execute_daemonized
      options = {:shim_prefix => @command_prefix}
      options[:sudo] = @stage.options[:sudo]
      options[:vm_name] = @service_node.service.name
      script = "cd #{@service_node.service.vm_root}; #{@stage.script}"
      script = script.gsub('\\', {'\\' => '\\\\'}).gsub('"', {'"' => '\\"'})
      @box.ssh("/bin/bash -c \"#{script}\"", options)
    end
  end
end

