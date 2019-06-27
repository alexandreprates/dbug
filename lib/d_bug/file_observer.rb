require 'rb-inotify'

module DBug
  # observer = FileObserver.new(".", exclude: ['.txt', '.html'])
  # observer.start_and_wait
  # observer.wait_event
  class FileObserver

    class << self
      def notifier
        @notifier ||= INotify::Notifier.new
      end
    end

    attr_reader   :path
    attr_accessor :event_filename

    def initialize(path, include, exclude)
      @path = path
      @include = include
      @exclude = exclude
      @event_filename = nil

      FileObserver.notifier.watch path, :modify, :recursive, &method(:handle)
    rescue Errno::ENOENT => e
      puts e
      exit 1
    end

    def start
      puts "monitoring #{path}"
      FileObserver.notifier.run
    end

    def wait_event
      puts "monitoring #{path}"
      FileObserver.notifier.process
    end

    def stop
      FileObserver.notifier.stop
    rescue ThreadError
      # piff `synchronize': can't be called from trap context
    end

    private

    def handle(event)
      filename = event.absolute_name
      notify(filename) if valid?(filename)
    end

    def notify(filename)
      return unless valid?(filename)

      @event_filename = filename
      if DBug::CommandRunner.running?
        puts "XXXX" * 1000
      else
        DBug.queue << { file_changed: filename }
      end
    end

    def valid?(filename)
      puts "[#{self.class.to_s}] only for #{filename} #{include?(filename)}" if DBug::DEBUG
      puts "[#{self.class.to_s}] exclude for #{filename} #{exclude?(filename)}" if DBug::DEBUG

      include?(filename) && !exclude?(filename)
    end

    def exclude?(filename)
      !!(@exclude && filename.end_with?(@exclude))
    end

    def include?(filename)
      !(@include && !filename.end_with?(@include))
    end

  end
end