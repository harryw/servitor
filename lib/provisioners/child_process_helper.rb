module Servitor
  module ChildProcessHelper

    def execute_child_process(*args)
      options = args.pop if args.last.is_a? Hash
      options ||= {}
      puts "Executing: #{args.inspect}"
      process = ChildProcess.build(*args)
      if block_given?
        yield process
      else
        process.io.inherit!
      end
      process.start
      exit_code = process.wait
      unless exit_code == 0 || options[:ignore_exit_code]
        raise ServitorChildProcessError, "#{args.inspect}: exited with code #{exit_code}"
      end
    end

    def execute_child_process_and_capture_output(*args)
      output = nil
      Tempfile.open('ChildProcessHelper') do |tempfile|
        execute_child_process(*args) do |process|
          process.io.stdout = process.io.stderr = tempfile
        end
        tempfile.rewind
        output = tempfile.read
      end
      output
    end

    def self.included(base)
      # this can work as a class method too
      base.extend(ChildProcessHelper)
    end

  end

  class ServitorChildProcessError < StandardError; end
end
