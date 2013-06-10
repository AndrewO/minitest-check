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

#SimpleSpec = describe "MyClass" do
class SimpleSpec < Minitest::Spec
  check "add" do |a, b|
    collect(:input, [a, b])
    #puts "checking with #{a}, #{b}"
    assert_equal(collect(:output, MyClass.new.add(a, b)), a + b)
  end

  check "maybe add" do |b, c|
    actual = MyClass.new.add(c, b)
    if c
      assert_equal(actual, c + b)
    else
      assert_equal(actual, nil)
    end
  end
end

# Some general tests
SimpleSpec.seed(100) do |i|
  {a: rand(i), b: rand(i * 2), c: rand(i * 3) }
end

# Make sure we test with c as nil at least once
SimpleSpec.seed_value(a: 1, b: 2, c: nil)

