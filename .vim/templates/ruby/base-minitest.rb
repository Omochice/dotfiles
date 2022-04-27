require "minitest/autorun"

class TestClass < Minitest::Test
  def test_sample
    assert true
    refute false
    # (expected, actual)
    assert_equal(2, 1 + 1)
    assert_instance_of(Integer, 1)
  end
end
