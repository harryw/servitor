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

module Servitor
  def self.root
    @root
  end

  def self.root=(path)
    raise ServitorRootException, 'Servitor root has already been set; it can only be set once.' if @root
    @root = path
  end

  def self.boxes_root
    File.join(Servitor.root, '.servitor', 'boxes')
  end

  class ServitorRootException < StandardError; end
end