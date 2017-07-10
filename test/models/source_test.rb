require 'test_helper'

class SourceTest < ActiveSupport::TestCase

  def setup
    @source = Source.new(name: "Example Source")
  end

  test "should be valid" do
    assert @source.valid?
  end

  test "name should be present" do
    @source.name = "     "
    assert_not @source.valid?
  end
end
