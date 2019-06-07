require 'open3'

module DBug
  class CommandRunner

    def initialize(queue, command)
      @queue = queue
      @command = command
    end

    def call
      notify_start

      Open3.popen3(@command) do |_, stdout, stderr, thread|
        th_read stdout
        th_read stderr

        thread.join # don't exit until the external process is done
        notify_complete thread.value.success?
      end
    end

    private

    def notify_start
      @queue << {exec_start: @command}
    end

    def notify_complete(success)
      status = success ? :success : :failure
      @queue << {exec_end: {@command => status}}
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
