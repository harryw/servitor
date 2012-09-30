class Infrastructure
  attr_writer :ports
  attr_accessor :deploy_root

  def ports
    @ports || {}
  end

end