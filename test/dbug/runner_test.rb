require "test_helper"

class RunnerTest < Minitest::Test

  def setup
    @queue = Queue.new
  end

  def test_process_success
    assert DBug::Runner.call(@queue, "exit 0")
    refute_empty @queue
    assert_equal({runner_start: "exit 0"}, @queue.pop)
    refute_empty @queue
    assert_equal({runner_end: :success}, @queue.pop)
  end

  def test_process_failure
    refute DBug::Runner.call(@queue, "exit 1")
    refute_empty @queue
    assert_equal @queue.pop, runner_start: "exit 1"
    refute_empty @queue
    assert_equal @queue.pop, runner_end: :failure
  end

  def test_process_stdout
    assert_output("STDOUT TEST\n", "") { DBug::Runner.call(@queue, "echo STDOUT TEST") }
  end

end