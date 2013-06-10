# Minitest::Check

Writing tests is easy in Ruby—there are so many tools and TDD is ingrained in the culture. However, with all of that emphasis on testing, isn't it a shame that we spend so much time testing against the same data? All we end up proving is that our code runs well against a certain class of hand-picked inputs which may or may not resemble our real-world data.

What we need is a way to express invariants over a domain: given a class of inputs, our code should produce a certain class of outputs.

This library provides three things:

1. A means to parameterize tests so that the same test can be run with different inputs and those inputs are clear to other developers.
2. A means to seed the test suite with the data to run. This could be from a generator that returns a certain type of objects for unit testing, or from an external data source if you wish to validate integration data. 
3. A means to collect data from inside your tests. In the future, you will be able to make assertions on these to test invariants over the entire suite (e.g.: author.books.length should follow a power distribution.)

For now, see the examples for more documentation.

## Future Directions

The initial versions of this library are meant to work with the version of minitest found in Ruby 1.9.3-p327. More current versions of minitest are a good deal easier to extend. My goal is to have a stable version of this that can run against the stock minitest, with future development using a later one. When I make this switch, there will be a major version bump.

As mentioned above, I'm planning on adding the ability to add assertions on collectors. Fortunately, minitest/benchmark has already done most of the statistics work for me there.

Lastly, I'm looking into modifying the Minitest runner to run using an Enumerator of callables, rather than it's current instance method based implementation. This would allow the test runner to operate continuously (with the right data generator).

## Installation

Add this line to your application's Gemfile:

    gem 'minitest-check'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest-check

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
