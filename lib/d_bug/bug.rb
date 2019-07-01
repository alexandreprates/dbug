require 'rubyserial'

module DBug
  class Bug
    attr_reader :port, :connected, :status

    PROTOCOL_STATUS = %i{off blink success failure unknow}.freeze

    def initialize(port)
      @port = port
      @status = nil
      @blinking = false
      @connected = false
    end

    def off!
      notify(false, :off)
    end

    def unknow!
      set_status :unknow
      notify
    end

    def success!
      printf "suit returned success, "
      set_status :success
      notify(true)
    end

    def failure!
      printf "suit returned failure, "
      set_status :failure
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

    def set_status(status)
      DBug.semaphore.synchronize { @status = status }
    end

    def notify(feedback = false, status = nil)
      status_code = PROTOCOL_STATUS.index(status || @status)
      puts "[#{self.class.to_s}] Receive notification update" if DBug::DEBUG

      if serial
        puts "notifing bug!" if feedback
        result = serial.write(status_code.chr)
        puts "[#{self.class.to_s}] Send to bug #{status_code} => #{result}" if DBug::DEBUG
      else
        puts "running in steath mode nobody will be notified!" if feedback
      end
    end

    def blink_thread
      Thread.new do
        loop do
          notify(false, :blink)
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
