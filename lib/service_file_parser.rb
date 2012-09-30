require 'service_config'

class ServiceFileParser

  # Parses the given service file, returning a service config
  def self.parse(file)
    ServiceConfig.new(file).tap {|sc| sc.instance_eval(File.read(file))}
  end

end