module Servitor
  module ChildProcessHelper

    def execute_child_process(*args)
      puts "Executing: #{args.inspect}"
      process = ChildProcess.build(*args)
      process.io.inherit!
      process.start
      exit_code = process.wait
      raise ServitorChildProcessError, "#{args.inspect}: exited with code #{exit_code}" unless exit_code == 0
    end

    def self.included(base)
      # this can work as a class method too
      base.extend(ChildProcessHelper)
    end

  end

  class ServitorChildProcessError < StandardError; end
end