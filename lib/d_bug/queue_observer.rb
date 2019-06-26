module DBug

  # observer = QueueObserver.new(queue, process_runner, serial_conn)
  # observer.start
  # observer.wait_event
  class QueueObserver

    def initialize(handler)
      @handler = handler
    end

    def start(block = false)
      Thread.new do
        while event = DBug.queue.pop do
          puts "[#{self.class.to_s}] Queue dispatch #{event.inspect}" if DBug::DEBUG
          deliver(event)
        end
      end
      thread.join if block
    end

    def wait_event
      deliver(event) if event = DBug.queue.pop
    end

    def stop
      DBug.queue.close
    end

    private

    def deliver(event)
      @handler.dispatch(event)
    end

  end

end
