module Servitor
  class ServiceLinker

    attr_reader :service_nodes, :service_box_names

    def initialize(service_nodes, service_box_names)
      @service_nodes = service_nodes
      @service_box_names = service_box_names
    end

    # Transforms the list of service nodes to a list of services.  Service nodes
    # describe the requirements and dependencies of each app, while services describe
    # the VMs that satisfy those requirements and dependencies.
    def link(options={})
      ip_block = options[:ip_block] || '192.168.51'
      next_ip = (options[:first_ip] || 0).to_i
      next_port = (options[:first_port] || 3000).to_i
      @service_nodes.map do |service_node|
        service = Service.new
        puts "service_node.service_config is: #{service_node.service_config.inspect}"
        service.name = service_node.service_config.name
        service.box = @service_box_names[service_node]
        service.ip_address = "#{ip_block}.#{next_ip}"
        next_ip += 1
        service.forwarded_ports = { 80 => next_port }
        next_port += 1
        service
      end
    end

  end
end