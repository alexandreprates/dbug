require 'open3'

module DBug
  module Runner

    module_function

    def call(queue, command)
      @queue = queue

      notify_runner_start(command)
      Open3.popen3(command) do |stdin, stdout, stderr, thread|
        { :out => stdout, :err => stderr }.each do |key, stream|
          Thread.new do
            until (!stream.closed? && line = stream.gets).nil? do
              puts line
            end
          end
        end
        thread.join # don't exit until the external process is done

        notify_runner_complete thread.value.success?
      end
    end

    def notify_runner_start(command)
      @queue << { runner_start: command }
    end

    def notify_runner_complete(success)
      @queue << {runner_end: success ? :success : :failure}
      success
    end

  end
end
