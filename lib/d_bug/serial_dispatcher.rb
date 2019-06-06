require 'rubyserial'

module DBug
  class SerialDispatcher

    def initialize(source)
      @serial = Serial.new source, 57600
    end

    def send(message)
      @serial.write(message)
    end

  end
end
