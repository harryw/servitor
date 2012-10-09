module Servitor

  class VagrantBoxRubyProvisioner < VagrantBoxProvisioner
    attr_reader :requirements

    def initialize(requirements)
      super(VagrantBaseboxProvisioner.new(requirements))
      @requirements = requirements
    end

    def name
      "#{base_provisioner.name}_ruby-#{@requirements.ruby_version}".gsub(/[^a-zA-Z0-9\-]/, '-')
    end

    def setup(box)
      box.ssh('which curl || sudo apt-get install curl -y')
      case @requirements.ruby_version
      when /jruby/
        box.ssh('sudo apt-get install g++ openjdk-6-jre-headless -y')
      when /ironruby/
        box.ssh('sudo apt-get install mono-2.0-devel -y')
      else
        box.ssh('sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config -y')
      end
      box.ssh('which rvm || curl -L https://get.rvm.io | bash -s stable; echo "avoiding RVM exit code 1"')
      box.ssh('which curl || sudo apt-get install curl -y')
      box.ssh("rvm install #{@requirements.ruby_version}; echo 'avoiding RVM exit code 5'")
      box.ssh("rvm use #{@requirements.ruby_version} --default")
    end

  end

end
