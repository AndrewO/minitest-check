$:.unshift("lib")
require "minitest/autorun"
require "minitest-check"

class MyClass
  def add(x, y)
    if x && y
      x + y
    else
      nil
    end
  end
end

class SimpleTest < MiniTest::Unit::TestCase
  def check_add(a, b)
    collect(:input, [a, b])
    #puts "checking with #{a}, #{b}"
    assert_equal(collect(:output, MyClass.new.add(a, b)), a + b)
  end

  def check_maybe_add(b, c)
    actual = MyClass.new.add(c, b)
    if c
      assert_equal(actual, c + b)
    else
      assert_equal(actual, nil)
    end
  end
end

# Some general tests
SimpleTest.seed(100) do |i|
  {a: rand(i), b: rand(i * 2), c: rand(i * 3) }
end

# Make sure we test with c as nil at least once
SimpleTest.seed_value(a: 1, b: 2, c: nil)
