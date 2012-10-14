module Servitor

  class AppDescription

    %w(build release).each do |attr|
      define_method(attr) do |*args|
        value = args.length > 0 ? args.first : nil
        attr_sym = "@#{attr}".to_sym
        instance_variable_set(attr_sym, value) unless value.nil?
        instance_variable_get(attr_sym)
      end
    end

    alias :configure :build
    alias :execute :release

  end

end
