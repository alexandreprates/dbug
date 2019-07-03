require 'rb-inotify'

module DBug
  # observer = FileObserver.new(".", exclude: ['.txt', '.html'])
  # observer.start_and_wait
  # observer.wait_event
  class FileObserver

    class << self

      def last_event=(event)
        DBug.semaphore.synchronize { @last_event = event }
      end

      def last_event
        DBug.semaphore.synchronize { @last_event }
      end

    end

    attr_reader   :path
    attr_accessor :event_filename

    def initialize(path, include, exclude)
      @path = path
      @include = include
      @exclude = exclude
      @event_filename = nil

      DBug.notifier.watch path,    :modify, :recursive, &method(:handle)
      DBug.notifier.watch "/dev/", :create, &method(:handle_usb)
    rescue Errno::ENOENT => e
      puts e
      exit 1
    end

    def start
      puts "monitoring #{path}"
      DBug.notifier.run
    end

    def wait_event
      puts "monitoring #{path}"
      DBug.notifier.process
    end

    def stop
      DBug.notifier.stop
    rescue ThreadError
      # piff `synchronize': can't be called from trap context
    end

    private

    def handle(event)
      filename = event.absolute_name
      notify(filename) if valid?(filename)
    end

    def handle_usb(event)
      DBug.bug.reconnect! if event.absolute_name == "/dev/serial"
    end

    def notify(filename)
      if flood?(filename)
        puts "[#{self.class.to_s}] flood event #{filename}" if DBug::DEBUG
        return
      end

      self.class.last_event = [Time.now.to_i, filename]

      @event_filename = filename
      puts "[#{self.class.to_s}] Ignored event #{filename}, suit is running" if DBug::CommandRunner.running? && DBug::DEBUG
      DBug.queue << { file_changed: filename } unless DBug::CommandRunner.running?
    end

    def flood?(filename)
      event_timestamp, event_filename = self.class.last_event
      !!(event_timestamp && event_filename == filename && event_timestamp > (Time.now.to_i - 5))
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