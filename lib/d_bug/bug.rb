require 'rubyserial'

module DBug
  class Bug
    attr_reader :port, :connected, :status

    STATUS = %i{off blink success failure unknow}.freeze

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
      notify(true)
    end

    def failure!
      printf "suit returned failure, "
      @status = :failure
      notify(true)
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

    def notify(feedback = false, status = nil)
      status_code = STATUS.index(status || @status)
      puts "[#{self.class.to_s}] Receive notification update" if DBug::DEBUG

      if serial
        puts "notifing bug!" if feedback
        result = serial.write(status_code)
        puts "[#{self.class.to_s}] Send to bug #{status_code} => #{result}" if DBug::DEBUG
      else
        puts "running in steath mode nobody will be notified!" if feedback
      end
    end

    def blink_thread
      Thread.new do
        loop do
          notify(false, :blink)
          sleep 3
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