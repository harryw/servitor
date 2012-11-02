module Servitor
  class EnvdirDeployer
    include ChildProcessHelper

    attr_reader :box, :path, :dirname, :variables

    def initialize(box, service_name, path, dirname, variables)
      @service_name = service_name
      @box = box
      @path = path
      @dirname = dirname
      @variables = variables
    end

    def deploy
      # envdir is part of daemontools
      box.ssh('which envdir || sudo apt-get install daemontools',
          :vm_name => @service_name, :ignore_exit_code => true, :capture => true)

      box.ruby(<<-RUBY, :vm_name => @service_name, :sudo => true)
        require 'fileutils'
        envdir = File.join(#{path.inspect}, #{dirname.inspect})
        variables = #{variables.inspect}
        FileUtils.rm_rf(envdir)
        FileUtils.mkdir_p(envdir)
        Dir.chdir(envdir) do
          variables.each do |name, value|
            File.open(name.upcase, 'w') {|f| f.write(value.gsub("\n", 0.chr)) } if value
          end
        end
      RUBY
    end
  end
end
