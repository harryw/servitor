require 'erubis'

class String
  unless method_defined?(:blank?)
    def blank?
      self =~ /^\s*$/
    end
  end
end

class NilClass
  unless method_defined?(:blank?)
    def blank?
      true
    end
  end
end

module Servitor

  class Vagrantfile
    def initialize(services, ssh_dir)
      @services = services
      @ssh_dir = ssh_dir
    end

    def generate
      template_path = File.join(File.dirname(__FILE__), 'Vagrantfile.erb')
      eruby = Erubis::Eruby.load_file(template_path)
      context = Erubis::Context.new(:services => @services, :ssh_dir => @ssh_dir)
      eruby.evaluate(context)
    end
  end
end
