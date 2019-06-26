require "test_helper"

class CommandRunnerTest < Minitest::Test

  def setup
    @queue = Queue.new
  end

  def test_call_success
    assert DBug::CommandRunner.new(@queue, ["exit 0"]).call("filaname")
  end

  def test_notifications_send_on_success
    DBug::CommandRunner.new(@queue, "exit 0").call("filaname")

    refute_empty @queue
    assert_equal({exec_start: "exit 0"}, @queue.pop)
    refute_empty @queue
    assert_equal({exec_success: "exit 0"}, @queue.pop)
  end

  def test_call_failure
    refute DBug::CommandRunner.new(@queue, "exit 1").call("filaname")
  end

  def test_notifications_send_on_failure
    DBug::CommandRunner.new(@queue, "exit 1").call("filaname")

    refute_empty @queue
    assert_equal({exec_start: "exit 1"}, @queue.pop)
    refute_empty @queue
    assert_equal({exec_failure: "exit 1"}, @queue.pop)
  end

  def test_read_and_display_stdout
    assert_output("STDOUT TEST\n", "") { DBug::CommandRunner.new(@queue, "echo STDOUT TEST").call("filaname") }
  end

  def test_read_and_display_stderr
    assert_output("STDERR TEST\n", "") { DBug::CommandRunner.new(@queue, "echo STDERR TEST >&2").call("filaname") }
  end

end