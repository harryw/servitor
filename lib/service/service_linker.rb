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
      next_ip = (options[:first_ip] || 2).to_i
      next_port = (options[:first_port] || 3000).to_i
      @service_nodes.map do |service_node|
        service = Service.new
        service.service_node = service_node
        service.name = service_node.service_definition.name
        service.box = @service_box_names[service_node]
        service.ip_address = ip_address(next_ip, options)
        begin
          next_ip += 1
        end while ip_address(next_ip, options) == host_ip(options)
        service.forwarded_ports = { 80 => next_port }.merge(ports_for(service_node))
        next_port += 1
        service.root = service_node.service_definition.service_root
        service.vm_root = options[:vm_root] || '/mnt/app/current'
        service
      end
    end

    private

    def ports_for(service_node)
      ports = {}
      if service_node.service_definition.configuration.resources.any? {|r| r.options[:type] == 'mysql'}
       # ports[3306] = 3306
      end
      ports
    end

    def ip_block(options)
      options[:ip_block] || '192.168.51'
    end

    def ip_address(next_ip, options)
      "#{ip_block(options)}.#{next_ip}"
    end

    def host_ip(options)
      "#{ip_block(options)}.1"
    end
  end
end
