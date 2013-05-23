require "minitest-check/version"
require "delegate"
require "ostruct"
require "minitest/unit"

module MiniTest
  class Unit
    def run_checks 
      _run_anything :check
    end

    class TestCase
      def self.check_suites
        TestCase.test_suites.reject {
          |s| s.check_methods.empty?
        }.map {|s|
          s.generate_suites
        }.flatten
      end

      def self.check_methods # :nodoc:
        public_instance_methods(true).grep(/^check_/).map { |m| m.to_s }.sort
      end
    end
  end


  module Check
    SeedSpec = Struct.new(:num, :generator)

    class SuiteWrapper < SimpleDelegator
      def initialize(suite, context)
        @context = OpenStruct.new(context)
        super(suite)

        @test_wrapper = Class.new(suite) do
          def initialize(name, context)
            @context = context
            super(name)
          end
        end
        check_methods.each do |name|
          m = instance_method(name)
          ps = m.parameters.map {|p| p[1]}
          @test_wrapper.send(:define_method, name) do
            puts "running #{name} with #{ps.map {|p| @context.send(p)}}"
            super(*ps.map {|p| @context.send(p)} )
          end
        end
      end
      
      def new(name)
        @test_wrapper.new(name, @context)
      end

      def check_suite_header(suite)
        puts "Checking with context: #{@context.inspect}"
      end
    end

    class TestCase < MiniTest::Unit::TestCase
      class << self
        def seed(i = 0, &blk)
          @seeds ||= []
          @seeds << SeedSpec.new(i, blk)
        end

        def generate_suites
          generate_contexts.map {|c| SuiteWrapper.new(self, c) }
        end

        # private
        def generate_contexts
          @seeds.map {|s|
            s.num.times.map {|i| s.generator.call(i) }
          }.flatten
        end
      end
    end
  end
end
