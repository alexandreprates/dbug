require "test_helper"

class DBugTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DBug::VERSION
  end

end
