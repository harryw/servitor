class ServiceConfig

  # these are part of the service configuration file
  attr_accessor :name, :command, :depends_on

  # these are derived at load time
  attr_reader :location

  def initialize(location)
    @location = location
    @depends_on = []
  end

end