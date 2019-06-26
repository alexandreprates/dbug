require 'open3'

module DBug
  class CommandRunner

    REPLACE_STRING = "{}".freeze

    def initialize(*command)
      puts "[#{self.class.to_s}] new command #{command.inspect}" if DBug::DEBUG
      @command = command.flatten
    end

    def call(filename, silence = false)
      notify_start
      puts "[#{self.class.to_s}] running #{inject_filename(filename).inspect}" if DBug::DEBUG
      Open3.popen3(*inject_filename(filename)) do |_, stdout, stderr, thread|
        th_read stdout unless silence
        th_read stderr unless silence
        thread.join # don't exit until the external process is done
        puts "[#{self.class.to_s}] running complete" if DBug::DEBUG
        notify_complete(thread.value.success?)
      end
    rescue Errno::ENOENT => e
      puts "Can not run: #{readable_command}"
      exit 2
    end

    private

    def notify_start
      DBug.queue << {exec_start: readable_command}
    end

    def notify_complete(success)
      puts "[#{self.class.to_s}] notify #{success.inspect}" if DBug::DEBUG
      if success
        DBug.queue << {exec_success: readable_command}
      else
        DBug.queue << {exec_failure: readable_command}
      end
      success
    end

    def inject_filename(filename)
      @command.collect { |item| item.gsub(REPLACE_STRING, filename) }
    end

    def readable_command
      @command.join(" ")
    end

    def th_read(stream)
      Thread.new do
        while (!stream.closed? && line = stream.gets) do
          puts line
        end rescue nil
      end
    end

  end
end
