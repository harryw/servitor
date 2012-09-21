#!/usr/bin/ruby

## Runs dependent services in a SOA

service_config = ServiceLocator.locate
graph = ServiceGraphBuilder.build(service_config)

service_configs = ServiceGraphFlattener.flatten_to_startup_order(graph)

