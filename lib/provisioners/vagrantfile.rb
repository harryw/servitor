require 'erubis'

module Servitor

  class Vagrantfile
    attr_reader :services

    def initialize(services)
      require 'pp'
      puts "services are: #{services.pretty_inspect}"
      @services = services
    end

    def generate
      template_path = File.join(File.dirname(__FILE__), 'Vagrantfile.erb')
      eruby = Erubis::Eruby.load_file(template_path)
      context = Erubis::Context.new(:services => services)
      eruby.evaluate(context)
    end
  end
end
