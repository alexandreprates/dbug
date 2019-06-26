require "test_helper"

class FileObserverTest < Minitest::Test

  def setup
    @queue = Queue.new
    @observer = DBug::FileObserver.new(@queue, "./test/observable", "ignore.me")
  end

  def trap(filename)
    Thread.new do
      sleep 0.5
      filename = File.join("./test/observable", filename)
      File.open(filename, "w+")
    rescue Exception => e
      puts "Exception: #{e}"
    end
  end

  def test_notify_file_changed
    trap("sample.txt")
    @observer.wait_event

    refute_empty @queue
    assert_equal({file_changed: "./test/observable/sample.txt"}, @queue.pop)
  end

  def test_ignore_file_changed
    trap("ignore.me")
    @observer.wait_event

    assert_empty @queue
  end

end
