require 'zlib'

module Servitor

  class InfrastructureRequirements

    %w(os_name os_version os_arch
      chef_repo chef_refspec chef_runlist chef_attributes
      ruby_version).each do |attr|
      define_method(attr) do |*args|
        value = args.length > 0 ? args.first : nil
        attr_sym = "@#{attr}".to_sym
        instance_variable_set(attr_sym, value) unless value.nil?
        instance_variable_get(attr_sym)
      end
    end

    # Returns a hash of the requirements that should be consistent between processes
    def consistent_hash
      Zlib.crc32(self.to_yaml, 0)
    end

  end

end
