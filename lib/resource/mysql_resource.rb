module Servitor
  class MysqlResource

    USERNAME = 'root'
    PASSWORD = ''

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
          build <<-BASH
            which mysqld || sudo apt-get install mysql-server -y
          BASH
          release <<-BASH
            SERVICE_IP = ifconfig eth1 | sed '/inet addr/!d;s/.*addr:\(.*\) Bcast.*$/\1/'
            sudo sed -i '/^bind-address/s/127.0.0.1/$SERVICE_IP/g' /etc/mysql/my.cnf
          BASH
          run <<-BASH
            sudo service mysql restart
          BASH
        end
        service_definition
      end
    end
  end
end
