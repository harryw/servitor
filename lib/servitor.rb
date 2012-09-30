module ServitorRequire
  if Kernel.respond_to?(:require_relative)
    def servitor_require(path)
      require_relative(path)
    end
  else
    def servitor_require(path)
      require(File.join(File.dirname(caller[1]), path))
    end
  end
end

Kernel.extend(ServitorRequire)

servitor_require 'cli/cli'
servitor_require 'infrastructure/infrastructure'
servitor_require 'provisioners/provisioners'
servitor_require 'service/service'
