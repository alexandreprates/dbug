module DBug
  module MessageHandler
    extend self

    @handlers = {}

    def handle(event, &handler)
      puts "[#{self.to_s}] register handler for #{event}" if DBug::DEBUG
      !!(@handlers[event] = handler)
    end

    def dispatch(event_data)
      puts "[#{self.to_s}] dispatch #{event_data.inspect}" if DBug::DEBUG
      event, data = event_data.flatten
      return false unless @handlers.has_key?(event)

      @handlers[event].call(data)
    end

  end
end