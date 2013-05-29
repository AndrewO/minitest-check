require "minitest-check/version"
require "delegate"
require "ostruct"
require "minitest/unit"
require "observer"
require "set"

module MiniTest
  class Unit
    attr_reader :collector
    def run_checks 
      @collector = Check::Collector.new
      _run_anything :check
      @collector.report
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

      class << self
        def contexts
          @contexts or superclass.respond_to?(:contexts) ? superclass.contests : []
        end

        def check_with(generator)
          @contexts ||= []
          # It would be nice if Minitest lazily iterated through its tests, calling one-by-one.
          # Then we could feed new tests into the generator as the system run or depending on
          # external data sources. It's a departure from the unit testing that Minitest is built for,
          # but it is a use-case I'm trying to cover here.
          @contexts += generator.to_a
        end

        # Convenience method to run a block a certain number of times
        def seed(num = 1, &blk)
          check_with(Enumerator.new {|contexts| num.times {|i| contexts << blk.call(1)}})
        end

        def seed_value(hash_or_object)
          check_with([hash_or_object])
        end

        def generate_suites
          contexts.map {|c| Check::SuiteWrapper.new(self, c) }
        end
      end
    end
  end


  module Check
    class SuiteWrapper < SimpleDelegator
      def initialize(suite, context)
        @context = context.kind_of?(Hash) ? OpenStruct.new(context) : context
        super(suite)

        @test_wrapper = Class.new(suite) do
          include Observable
          attr_reader :context
          def initialize(name, _context)
            # Getting a little gnarly here...
            method = self.class.superclass.instance_method(name)
            params = method.parameters.map {|p| p[1]}
            @context = Hash[params.map {|p| [p, _context.send(p)] }]

            super(name)
          end
          
          def run(runner)
            add_observer(runner.collector)
            super(runner).tap do
              runner.report[-1] += " Context: #{@context.inspect}" unless @passed
            end
          end

          private
          def collect(stat_name, stat_value)
            changed
            notify_observers("#{self.class.name}##{self.__name__}:#{stat_name}", stat_value)#, @context) Waiting until I know how we want to display contexts
          end
        end
        check_methods.each do |name|
          # TODO: fewer horrible metaprogramming hacks
          @test_wrapper.send(:define_method, name) do
            super(*@context.values)
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

    class Collector
      Record  = Struct.new(:count, :contexts)

      def initialize
        # TODO: better storage mechanism
        # Creates a hash like:
        #
        #  {
        #   "stat_foo" => {
        #     "value_1" => Record.new(count, Set of contexts producing this value)
        #   }
        # }
        @store = Hash.new {|s, n|
          s[n] = Hash.new {|n, v|
            n[v] = Record.new(0, Set.new)
          }
        }
      end

      def update(name, value, context = nil)
        @store[name][value].count += 1
        @store[name][value].contexts << context
      end

      def report
        # TODO: something better
        puts @store.inspect
      end
    end

    class Spec
      class << self
        def check name, &block
          define_method "check_#{name.gsub(/\W+/, '_')}", &block
        end
        # Make the Haskell people happy. :)
        alias_method :prop, :check
      end
    end
  end
end
