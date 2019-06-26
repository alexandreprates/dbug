require 'rubyserial'

module DBug
  class Bug
    attr_reader :port, :connected, :status

    STATUS = %i{unknow success failure}.freeze

    def initialize(port)
      @port = port
      @status = nil
      @blinking = false
      @connected = false
    end

    def off!
      @status = :off
      notify
    end

    def unknow!
      @status = :unknow
      notify
    end

    def success!
      printf "suit returned success, "
      @status = :success
      notify
    end

    def failure!
      printf "suit returned failure, "
      @status = :failure
      notify
    end

    def blinking(&block)
      thread = blink_thread
      yield
      thread.kill
    end

    def stealth?
      !serial
    end

    private

    def notify
      status_code = STATUS.index(@status)
      puts "[#{self.class.to_s}] Send do bug #{status_code}" if DBug::DEBUG

      if serial
        puts "notifing bug!"
        serial.write status_code
      else
        puts "running in steath mode nobody will be notified!"
      end
    end

    def blink_thread
      Thread.new do
        loop do
          notify
          sleep 2
        end
      end
    end

    def serial
      @serial ||= Serial.new port, 9600
    rescue RubySerial::Error
      @serial = nil
    end

  end
end