require "test_helper"

describe DBug do

  it "have a version" do
    DBug::VERSION.must_match(/0.1.0.[0-9]*$/)
  end

end
