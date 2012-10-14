module Servitor

  class ServiceFileParser

    # Parses the given service file, returning a service config
    def self.parse(file)
      file_content = File.read(file)
      ServiceConfig.new(file).tap do |sc|
        sc.instance_exec do
          eval(file_content)
        end
      end
    end

  end

end
