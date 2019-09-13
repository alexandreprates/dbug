require_relative "d_bug/version"

require_relative "d_bug/bug"
require_relative "d_bug/cli"
require_relative "d_bug/command_runner"
require_relative "d_bug/file_observer"
require_relative "d_bug/message_handler"
require_relative "d_bug/event_reactor"

STDOUT.sync = true

module DBug
  class Error < StandardError; end

  def self.debug?
    @options&.debug
  end

  MessageHandler.handle(:file_changed) do |param|
    puts "file #{param.inspect} changed running suit...\n\n"
    puts "#{'-' * 120}\n#{'TEST SUIT STDOUT'.center(120)}\n#{'-' * 120}\n"
    bug.blinking { CommandRunner.new(@options.command).call(param) }
  end

  # MessageHandler.handle(:exec_start) { |param|
  #   #code
  # }

  MessageHandler.handle(:exec_success) do |param|
    puts "#{'-' * 120}\n\n"
    bug.success!
  end

  MessageHandler.handle(:exec_failure) do |param|
    puts "#{'-' * 120}\n\n"
    bug.failure!
  end

  module_function

  def call(options)
    if options[:version]
      puts "d-bug: #{DBug::VERSION}"
      exit 0
    end

    puts "Starting d-bug!"
    @options = options

    puts("running in stealth mode...") if bug.stealth?
    bug.unknow!

    event_reactor.start
    file_observer.start
  end

  def stop
    puts "\nStopping..."
    bug.off!
    file_observer.stop && event_reactor.close
  end

  def queue
    @queue ||= Queue.new
  end

  def bug
    @bug ||= Bug.new
  end

  def notifier
    @notifier ||= INotify::Notifier.new
  end

  def file_observer
    @file_observer ||= FileObserver.new @options.path, @options.only, @options.exclude
  end

  def event_reactor
    @event_reactor ||= EventReactor.new queue: queue, handler: MessageHandler
  end

  def semaphore
    @semaphore ||= Mutex.new
  end

end
