require 'rubyserial'

module DBug
  class Bug
    attr_reader :connected, :status

    PROTOCOL_STATUS = %i{off blink success failure unknow}.freeze

    def initialize()
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

    def sync
      notify
    end

    def blinking(&block)
      self.unknow!
      thread = blink_thread
      yield
      thread.kill
    end

    def stealth?
      !serial
    end

    def reconnect!
      @serial = nil
    end

    private

    def set_status(status)
      DBug.semaphore.synchronize { @status = status }
    end

    def notify(feedback = false, status = nil)
      status_code = PROTOCOL_STATUS.index(status || @status)
      puts "[#{self.class.to_s}] Receive notification update" if DBug.debug?

      if serial
        puts "notifing bug!" if feedback
        result = serial.write(status_code.chr)
        puts "[#{self.class.to_s}] Send to bug #{status_code} => #{result}" if DBug.debug?
      else
        puts "running in steath mode nobody will be notified!" if feedback
      end
    rescue RubySerial::Error => e
      @serial = nil
    end

    def blink_thread
      Thread.new do
        loop do
          notify(false, :blink)
          sleep 2.5
        end
      end
    end

    def serial
      puts "[#{self.to_s}] using port #{port.inspect}" if DBug.debug?
      @serial ||= Serial.new port, 9600
    rescue RubySerial::Error
      @serial = nil
    end

    def port
      return @port if @port && File.exist?(@port)
      @port = Dir['/dev/serial/by-id/*FTDI*'].first
    end

  end
end
