require 'service_config/app_description'
require 'service_config/infrastructure_requirements'

class ServiceConfig

  # these are part of the service configuration file
  attr_accessor :name, :command, :depends_on

  # these are derived at load time
  attr_reader :location

  def initialize(location)
    @location = location
    @depends_on = []
    @app_description = AppDescription.new
    @infrastructure_requirements = InfrastructureRequirements.new
  end

  def describe_app
    yield @app_description
  end

  def require_infrastructure
    yield @infrastructure_requirements
  end

end