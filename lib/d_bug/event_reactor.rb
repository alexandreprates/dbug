module DBug

  # reactor = EventReactor.new(queue, process_runner, serial_conn)
  # reactor.start
  # reactor.wait_event
  class EventReactor

    def initialize(queue:, handler:)
      @queue = queue
      @handler = handler
    end

    def start(block = false)
      Thread.new do
        while event = @queue.pop do
          puts "[#{self.class.to_s}] Queue dispatch #{event.inspect}" if DBug.debug?
          deliver(event)
        end
      end
      thread.join if block
    end

    def wait_event
      deliver(event) if event = @queue.pop
    end

    def stop
      @queue.close
    end

    private

    def deliver(event)
      @handler.dispatch(event)      
    end

  end

end
