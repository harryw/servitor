module Servitor

  class ServiceFileParser

    # Parses the given service file, returning a service config
    def self.parse(file, service_root)
      begin
      file_content = File.read(file)
      ServiceDefinition.new(file, service_root).tap do |sc|
        sc.instance_exec do
          eval(file_content)
        end
      end
      rescue StandardError => e
        raise e, "Error parsing #{file}: #{e.message}", e.backtrace
      end
    end

  end

end
