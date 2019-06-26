require 'rubyserial'

module DBug
  class SerialComm

    STATUS = {running: 3, success: 2, failure: 1}.freeze

    attr_reader :stealth

    def initialize(source)
      @stealth = false
      @serial = Serial.new source, 9600
      send(:running)
    rescue RubySerial::Error
      puts "can't connect to bug in #{source} check port/cable"
      @stealth = true
    end

    def notify(status)
      return unless status_code = STATUS[status]

      case [status, stealth]
      when [:success, false]
        puts "suit returned success, notifing bug!"
        send(status_code)
      when [:failure, false]
        puts "suit returned failure, notifing bug!"
        send(status_code)
      when [:success, true]
        puts "suit returned success, running in steath mode nobody will be notified!"
      when [:failure, true]
        puts "suit returned failure, running in steath mode nobody will be notified!"
      end
    end

    def send(data)
      puts "[#{self.class.to_s}] send #{data}" if DBug::DEBUG
      @serial.write data
    rescue Exception => e
      puts "Oops! #{e}\n#{caller.join("\n")}"
    end

    def read
      puts "SERIALREAD: #{@serial.read(255)}"
    end
  end
end
