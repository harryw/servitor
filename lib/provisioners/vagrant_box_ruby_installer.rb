module Servitor

  class VagrantBoxRubyInstaller
    attr_reader :requirements

    def initialize(requirements)
      @requirements = requirements
    end

    def install(box)
      return if already_installed?(box)
      box.ssh('which curl || sudo apt-get install curl -y')
      case @requirements.ruby_version
      when /jruby/
        box.ssh('sudo apt-get install g++ openjdk-6-jre-headless -y')
      when /ironruby/
        box.ssh('sudo apt-get install mono-2.0-devel -y')
      else
        box.ssh('sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config -y')
      end
      box.ssh('which rvm || curl -L https://get.rvm.io | bash -s stable', :ignore_exit_code => true)
      box.ssh('which curl || sudo apt-get install curl -y')
      box.ssh("rvm install #{@requirements.ruby_version}", :ignore_exit_code => true)
      box.ssh("rvm use #{@requirements.ruby_version} --default")
    end

    private

    def already_installed?(box)
      box.ssh('rvm current', :capture => true, :ignore_exit_code => true) == @requirements.ruby_version
    end
  end

end
