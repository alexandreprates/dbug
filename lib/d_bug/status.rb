module DBug
  class Status

    class InvalidStatus < StandardError; end

    STATUS = %i[unknow success failure].freeze

    attr_reader :current

    def initialize(queue)
      @queue = queue
      @current = :unknow
    end

    STATUS.each do |state|
      define_method("#{state}?") { current == state }
    end

    def change_to(state)
      raise InvalidStatus, "`#{state}` is not a valid state." unless valid_status?(state)
      return if state == @current

      @current = state
      notify_status_change
      state
    end

    def to_s
      current.to_s
    end

    private

    def valid_status?(status)
      STATUS.include?(status)
    end

    def notify_status_change
      @queue << {status_change: self.current}
    end

  end
end
