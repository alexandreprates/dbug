require "test_helper"

class StatusTest < Minitest::Test

  def setup
    @queue = []
    @status = DBug::Status.new(@queue)
  end

  def test_default_state
    assert_equal @status.current, :unknow
    refute @status.success?
    refute @status.failure?
    assert @status.unknow?
  end

  def test_success_state
    assert @status.unknow?
    assert_equal :success, @status.change_to(:success)
    assert_equal :success, @status.current
    assert @status.success?
    refute @status.failure?
    refute @status.unknow?
    refute_empty @queue
    assert_equal @queue[0], status_change: :success
  end

  def test_failure_state
    assert @status.unknow?
    assert_equal :failure, @status.change_to(:failure)
    assert_equal :failure, @status.current
    refute @status.success?
    assert @status.failure?
    refute @status.unknow?
    refute_empty @queue
    assert_equal @queue[0], status_change: :failure
  end

  def test_set_same_state
    assert_equal :failure, @status.change_to(:failure)
    @queue.pop

    assert_nil @status.change_to(:failure)
    assert_empty @queue
  end

end
