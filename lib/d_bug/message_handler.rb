module DBug
  class MessageHandler

    attr_reader :event

    def initialize(event, data)
      @event = event
      @data = data
    end

    def dispatch
      receipt.notified(data)
    end

    private

    def receipt()
      case event
      when :runner_start, :runner_end
        #
      when :observe_modify
        #
      end
    end

  end
end
