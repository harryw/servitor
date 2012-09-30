module Servitor

  class ServiceGraphFlattener

    class << self

      # Takes a service graph and returns the service configs in service startup order.
      # This means that services in the list depend only on other services
      # that appear later in the list.
      def flatten_to_startup_order(graph)
        nodes = []
        remaining_nodes = graph.service_nodes.values
        while remaining_nodes.any?
          found = false
          remaining_nodes.each do |node|
            if node.depends_on_nodes.none? { |depends_on_node| remaining_nodes.include?(depends_on_node) }
              found = true
              nodes << node
              remaining_nodes.remove(node)
              break
            end
          end
          raise CyclicDependencyError
        end
      end

    end

  end

  class CyclicDependencyError < StandardError; end

end