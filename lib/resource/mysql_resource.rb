module Servitor
  class MysqlResource

    USERNAME = 'root'
    PASSWORD = 'password'

    def self.service_definition
      @service_definition ||= begin
        service_definition = ServiceDefinition.new
        service_definition.name 'mysql'
        service_definition.infrastructure_requirements do
          os_name 'ubuntu'
          os_version '10.04'
          os_arch '64'
          ruby_version '1.9.2-p290'
        end
        service_definition.deployment_stages do
          build <<-BASH, :sudo => true
            echo checking for mysqld...
            if ! [ `which mysqld` ]; then
              echo installing mysql-server...
              echo mysql-server-5.1 mysql-server/root_password password #{PASSWORD} | debconf-set-selections
              echo mysql-server-5.1 mysql-server/root_password_again password #{PASSWORD}| debconf-set-selections
              apt-get update
              apt-get install mysql-server -y
              echo ...complete
            fi
          BASH
          release <<-RUBY, :language => :ruby, :sudo => true
            puts "configuring mysqld"
            puts `sed -i "/^bind-address/s/127.0.0.1/\#{ENV['SERVICE_IP']}/g" /etc/mysql/my.cnf`
          RUBY
          run <<-BASH, :sudo => true, :daemonized => true
            echo starting mysqld
            service mysql restart
          BASH
        end
        service_definition
      end
    end
  end
end
