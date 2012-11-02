# Servitor

Servitor is a tool for composing a Service Oriented Architecture (SOA) from a network
of services.

It is recommended that services should conform to the [12-Factor App](http://www.12factor.net/)
methodology.

Each service includes a Servicefile at the root of its codebase, declaring various properties
of the app that are fixed for any given version, such as:

* Runtime dependencies on other services
* Configurable variables
* Execution instructions
* Infrastructure requirements
* Resource dependencies

Given a set of required services, Servitor will build a dependency graph of those services
and all their implicit dependent services, construct a set of infrastructure upon which those
services can run, configure them appropriately, and execute them.

The principal goal of Servitor is to support the development of services that are part of an SOA,
allowing developers to perform local development and testing with real backing services rather
than using mocked local services or shared remote services.  This is achieved using
[Vagrant](http://vagrantup.com) to create local virtual machines, isolating each service and
allowing each service have different infrastructure requirements.

In the longer term, Servitor should become more flexible with alternative implementations of
its features, such as provisioning infrastructure from cloud providers (AWS, OpenStack, etc.)

For now, perhaps the most informative way to describe Servitor is with an example Servicefile:

```ruby
# The unique name of this service in the SOA
name 'my-service'

# This service may depend on any number of other services, identified by their
# unique names in the SOA.  Some services may depend on multiple instances of
# another service with different properties; this needs to be figured out.
depends_on %w( service2 service3 )

# Specify the infrastructure requirements for this service.  Anything that is
# not specified will revert to some defaults.  There may be additional
# infrastructure used in any given infrastructure provider implementation, but
# this is the minimum set required by the app.
infrastructure_requirements do
  os_name 'ubuntu'
  os_version '10.04'
  os_arch '64'
  ruby_version '1.9.2-p290'
end

# This should define the commands to use for the 12-factor build and release
# steps (also aliased as configure and execute).  Any other services that this
# service depends on will be started up first.  If there are mutual dependencies
# then they should both be built and configured and then both run.
deployment_stages do
  build 'echo "running build task"'
  release  'echo "running release task"'
  run 'rackup -p <%= @port %>'
end

# Any configurable variables for this app are defined here.  If the app is to
# receive configuration data then it *must* be included in this block.  This
# includes details of any backing resources (databases, queues, etc.) that need
# to be attached. If any of these are missing we can catch that problem without
# even starting the app.  We can also automate the configuration details that
# tell the app how to communicate with other services it depends on.
configuration do
  var 'config_var1'
  var 'config_var2'
  var 'config_var3', :default => 'some default'
  var 'service2_url', :domain_for => 'service2', :format => 'https://<%= @value %>'

  # If the service depends on attached resources, each resource can be configured
  # this way
  resource 'database', :type => 'mysql' do
    var 'database_host', :from => 'hostname'
    var 'database_name', :from => 'database_name'
    var 'database_username', :from => 'username'
    var 'database_password', :from => 'password'
  end

  # This configuration script will run in the context of another service, with the specified
  # arguments taken from the local configuration. The specified vars will be set from the output
  # of the script
  dependency_script 'register', :service => 'service2' do
    arg 'name', :from => :service_name
    var 'service_uuid'
    var 'private_key'
  end
end

# This is a configuration script provided by this service to other services that depend
# upon this one.  The specified args must be provided by the other service, and the given
# command will run with those args set as environment variables, with output sent to stdout
# as a single YAML mapping node.
provides_script 'frob' do
  command 'bundle exec ruby frob.rb'
  arg 'frobber'
end
```
