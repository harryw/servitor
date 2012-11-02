servitor_require 'service_definition/service_definition'
servitor_require 'service_graph/service_graph'
servitor_require 'service_file_parser'
servitor_require 'service_locator'
servitor_require 'service_linker'


module Servitor
  class Service
    attr_accessor :name, :box, :ip_address, :root, :vm_root, :forwarded_ports, :service_node
  end
end
