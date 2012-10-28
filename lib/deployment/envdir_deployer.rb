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
      box.ruby(<<-RUBY, :vm_name => @service_name)
        require 'fileutils'
        envdir = File.join(#{path.inspect}, #{dirname.inspect})
        variables = #{variables.inspect}
        FileUtils.mkdir_p(envdir)
        Dir.chdir(envdir) do
          variables.each do |name, value|
            File.open(name.upcase, 'w') {|f| f.write(value) }
          end
        end
      RUBY
    end
  end
end
