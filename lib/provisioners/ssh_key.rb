module Servitor
  class SshKey
    def initialize(ssh_dir)
      @ssh_dir = ssh_dir
    end

    def deploy
      FileUtils.mkdir_p(@ssh_dir)
      FileUtils.chmod(0700, @ssh_dir)
      home_ssh_dir = File.join(ENV['HOME'], '.ssh')
      private_key_file, public_key_file = %w(id_rsa id_rsa.pub).map do |key_file|
        original_key_file = File.join(home_ssh_dir, key_file)
        File.join(@ssh_dir, File.basename(original_key_file)).tap do |new_key_file|
          FileUtils.cp(original_key_file, new_key_file)
        end
      end
      FileUtils.chmod(0600, private_key_file)
      File.open(File.join(@ssh_dir, 'authorized_keys'), 'w') do |f|
        f.write(File.read(public_key_file))
      end
    end
  end
end
