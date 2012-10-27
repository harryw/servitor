module Servitor
  class BundleDeployer
    attr_reader :box, :path

    def initialize(box, path)
      @box = box
      @path = path
    end

    def deploy
      box.ssh("cd '#{path}'; bundle")
    end
  end
end
