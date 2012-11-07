require 'erubis'

module Servitor
  class DeploymentStageExecutor
    def initialize(box, vm_root, service_node, command_prefix)
      @box = box
      @service_node = service_node
      @command_prefix = command_prefix
      @vm_root = vm_root
    end

    def execute
      deploy_git_ssh
      build
      release
      run
    end

    private

    def build
      execute_stage(deployment_stages.build)
    end

    def release
      execute_stage(deployment_stages.release)
    end

    def run
      fork { execute_stage(deployment_stages.run, :detach_after => true) }
      sleep(10) # give it some time to start up
    end

    def execute_stage(stage, options={})
      if stage
        script = evaluate_template(stage.script)
        options.merge!(:vm_name => @service_node.service_definition.name)
        options.merge!(:sudo => stage.options[:sudo]) if stage.options[:sudo]
        if stage.options[:language] == :ruby
          wrapped_script = <<-RUBY
            ENV['GIT_SSH'] = #{git_ssh.inspect}
            ENV['SERVICE_IP'] = #{service_ip.inspect}
            #{script}
          RUBY
          @box.ruby(wrapped_script, options)
        else
          options[:shim_prefix] = @command_prefix
          script = script.gsub('\\', {'\\' => '\\\\'}).gsub('"', {'"' => '\\"'})
          script = "cd #{@vm_root} && GIT_SSH=#{git_ssh} SERVICE_IP=#{service_ip} /bin/bash -c \"#{script}\""
          script = script.gsub('\\', {'\\' => '\\\\'}).gsub('"', {'"' => '\\"'})
          @box.ssh("/bin/bash -c \"#{script}\"", options)
        end
      end
    end

    def evaluate_template(text)
      eruby = Erubis::Eruby.new(text)
      context = Erubis::Context.new(:port => 80)
      eruby.evaluate(context)
    end

    GIT_SSH_FILE = '.git_ssh'

    def deploy_git_ssh
      return if @service_node.service_definition.name == 'mysql'

      content = "ssh -i /mnt/ssh/id_rsa -o 'StrictHostKeyChecking no' $@"
      @box.ssh(<<-BASH, :vm_name => @service_node.service_definition.name)
        echo "#{content.gsub('$','\$')}" > #{File.join(@vm_root, GIT_SSH_FILE)}
        chmod ugo+x #{File.join(@vm_root, GIT_SSH_FILE)}
      BASH
    end

    def git_ssh
      return nil if @service_node.service_definition.name == 'mysql'

      "#{File.join(@vm_root, GIT_SSH_FILE)}"
    end

    def service_ip
      @service_node.service.ip_address
    end

    def deployment_stages
      @service_node.service_definition.deployment_stages
    end
  end
end
