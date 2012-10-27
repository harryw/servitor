module Servitor

  class ServiceLocator

    FILENAMES = %w(Servicefile .servicefile)
    DEFAULT_SERVICES_DIR = ENV['SERVITOR_SERVICES_DIR'] || File.join(ENV['HOME'],'git')

    class << self

      attr_writer :services_dir

      def services_dir
        @services_dir || DEFAULT_SERVICES_DIR
      end

      # Locates the local service or a named service, returning a service config
      def locate(service_name = nil)
        if service_name
          dir = File.join(services_dir, service_name)
        else
          dir = Dir.pwd
        end
        file = service_file_in_dir(dir)
        ServiceFileParser.parse(file, dir)
      end

      private

      def service_file_in_dir(dir)
        file_names = FILENAMES + FILENAMES.map { |f| File.join('config', f) }
        file_names.each do |file_name|
          service_file_name = File.join(dir, file_name)
          return service_file_name if File.exists?(service_file_name)
        end
        raise "No service file found in #{dir}"
      end

    end


  end

end
