module Servitor

  class InfrastructureRequirements

    %w(os_name os_version os_arch chef_repo chef_refspec chef_runlist chef_attributes).each do |attr|
      define_method(attr) do |value=nil|
        attr_sym = "@#{attr}".to_sym
        instance_variable_set(attr_sym, value) unless value.nil?
        instance_variable_get(attr_sym)
      end
    end

  end

end
