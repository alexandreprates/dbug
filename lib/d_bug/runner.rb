require 'open3'

module DBug
  class Runner

    def initialize(queue)
      @queue = queue
    end

    def exec(command)
      notify_start(command)

      Open3.popen3(command) do |_, stdout, stderr, thread|
        th_read stdout
        th_read stderr

        thread.join # don't exit until the external process is done
        notify_complete thread.value.success?
      end
    end

    private

    def notify_start(command)
      @queue << { runner_start: command }
    end

    def notify_complete(success)
      @queue << {runner_end: success ? :success : :failure}
      success
    end

    def th_read(stream)
      Thread.new do
        while (!stream.closed? && line = stream.gets) do
          puts line
        end
      end
    end

  end
end
