require_relative "d_bug/version"
require_relative "d_bug/cli"
require_relative "d_bug/command_runner"
require_relative "d_bug/file_observer"
require_relative "d_bug/message_handler"
require_relative "d_bug/queue_observer"
require_relative "d_bug/bug"

STDOUT.sync = true

module DBug
  class Error < StandardError; end

  # DEBUG = true
  DEBUG = false

  MessageHandler.handle(:file_changed) { |param|
    puts "file #{param.inspect} changed running suit...\n\n"
    puts "#{'-' * 120}\n#{'TEST SUIT STDOUT'.center(120)}\n#{'-' * 120}\n"
    bug.blinking { CommandRunner.new(@options.command).call(param) }
  }

  # MessageHandler.handle(:exec_start) { |param|
  #   #code
  # }

  MessageHandler.handle(:exec_success) { |param|
    puts "#{'-' * 120}\n\n"
    bug.success!
  }

  MessageHandler.handle(:exec_failure) { |param|
    puts "#{'-' * 120}\n\n"
    bug.failure!
  }

  module_function

  def call(options)
    puts "Starting d-bug!"
    @options = options

    puts("running in stealth mode...") if bug.stealth?
    bug.unknow!

    queue_observer.start
    file_observer.start
  end

  def stop
    puts "\nStopping..."
    bug.off!
    file_observer.stop && queue_observer.close
  end

  def queue
    @queue ||= Queue.new
  end

  def bug
    @bug = Bug.new @options.port
  end

  def file_observer
    @file_observer ||= FileObserver.new @options.path, @options.only, @options.exclude
  end

  def queue_observer
    @queue_observer ||= QueueObserver.new MessageHandler
  end

  def semaphore
    @semaphore ||= Mutex.new
  end

end
