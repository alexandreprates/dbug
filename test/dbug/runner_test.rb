require "test_helper"

class RunnerTest < Minitest::Test

  def setup
    @queue = Queue.new
    @runner = DBug::Runner.new(@queue)
  end

  def test_process_success
    assert @runner.exec("exit 0")
    refute_empty @queue
    assert_equal({runner_start: "exit 0"}, @queue.pop)
    refute_empty @queue
    assert_equal({runner_end: :success}, @queue.pop)
  end

  def test_process_failure
    refute @runner.exec("exit 1")
    refute_empty @queue
    assert_equal @queue.pop, runner_start: "exit 1"
    refute_empty @queue
    assert_equal @queue.pop, runner_end: :failure
  end

  def test_display_stdout
    assert_output("STDOUT TEST\n", "") { @runner.exec("echo STDOUT TEST") }
  end

  def test_display_stderr
    assert_output("STDERR TEST\n", "") { @runner.exec("echo STDERR TEST >&2") }
  end

end