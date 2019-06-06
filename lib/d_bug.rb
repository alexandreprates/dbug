require_relative "d_bug/version"
require_relative "d_bug/status"
require_relative "d_bug/runner"
require_relative "d_bug/serial_dispatcher"

module DBug
  class Error < StandardError; end

  module_function

  def call(path, command, exclude = [])
    @queue = Queue.new
    @notifier = INotify::Notifier.new

    @notifier.watch(folder, :modify, :recursive) do |event|
      @queue << { observe_modify: event.absolute_name } if exclude && !event.absolute_name.end_with(exclude)
    end

    @notifier.run
  end

  def stop
    @notifier&.stop
  end

end
