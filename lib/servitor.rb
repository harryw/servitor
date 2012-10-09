module ServitorRequire
  # for 1.8 compatibility
  def servitor_require(path)
    require(File.join(File.dirname(caller[0]), path))
  end
end

extend(ServitorRequire)

servitor_require 'cli/cli'
servitor_require 'infrastructure/infrastructure'
servitor_require 'provisioners/provisioners'
servitor_require 'service/service'
