---
layout: post
title: Testing Capistrano recipes for dummies
location: Clermont-Fd Area, France
updates:
  - date: 2022-04-18
    content: I proofread this article and fixed some links.
---

A couple months ago, I [took the lead of capifony][post-capifony], a set of
[Capistrano][] recipes for [Symfony](http://symfony.com) projects. I tried to
revamp the project and one of my goals was to add tests. This article presents
my work on that topic.

## Making your recipe testable

In order to make a Capistrano recipe testable, a common practice is to create a
module that can extends a Capistrano configuration instance:

```ruby
module MyRecipe
  def self.load_into(configuration)
    configuration.load do
      # Your code here
      # ...
    end
  end
end

if Capistrano::Configuration.instance
  MyRecipe.load_into(Capistrano::Configuration.instance)
end
```

The last three lines are needed to keep the original behavior of your recipe,
assuming you have an existing recipe that doesn't follow this practice.

Now you are ready to test your recipe, but _how?_ [capistrano-spec][] to the
rescue! **capistrano-spec** brings [RSpec][] to the Capistrano world so that
you can easily test your recipes. It has been created by [Josh
Nichols](https://github.com/technicalpickles).

### Installing capistrano-spec

The first step is to create a `spec/spec_helper.rb` file used to load everything
to run your tests. This file should look like this:

```ruby
# Bundler
require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'capistrano-spec'
require 'rspec'
require 'rspec/autorun'

# Add capistrano-spec matchers and helpers to RSpec
RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers
end

# Require your lib here
require 'my_recipe'
```

As you may have noticed, [Bundler][] is used to manage the dependencies. The
`Gemfile` file should contain the following content:

```ruby
source 'http://rubygems.org'

gemspec

gem 'rake'
gem 'rspec'
gem 'capistrano-spec'
```

`gemspec` loads all the dependencies located in the `.gemspec` file, which is
used to build your _gem_. For more information, please read [Using Bundler with
Rubygem gemspecs][bundler-rubygems].

Also, a best practice here is to rename your `Gemfile` to `.gemfile` because
it is used for testing purposes only. It's not a big deal but it makes your
project a bit "cleaner".

Run the command below to install your dependencies:

    BUNDLE_GEMFILE=.gemfile bundle install

You also need a `Rakefile` file to configure [Rake][]. It is similar to `make`
and it allows to run a set of tasks written in Ruby. In order to run your test
files ("examples" in RSpec), you need a `spec` task. The following snippet is
all you need:

```ruby
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = '--color --format=documentation -I lib -I spec'
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
```

Now you probably want to write your first test file, and you are right! Let's
do it!

## Writing your first test

Create a new file named `spec/my_recipe_spec.rb` and add the content below:

```ruby
require 'spec_helper'

describe "MyRecipe" do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)

    MyRecipe.load_into(@configuration)
  end

  # Your code here
end
```

We create a Capistrano configuration instance and we extend it with capistrano-spec.
This configuration instance is injected into our module.

Try to run the `spec` task using the following command:

    BUNDLE_GEMFILE=.gemfile bundle exec rake spec

You should see:

    Finished in 0.00006 seconds
    0 examples, 0 failures

If everything looks good, congratulations! Time to write your **examples**. Yes,
in Rspec, you don't really write "tests", you write **executable examples** of
the expected behaviors of your code.

First, declare the `@configuration` variable as subject:

```ruby
subject { @configuration }
```

It tells RSpec what we are going to test. Instead of writing something like:

```ruby
it { @configuration.should have_run('pwd') }
```

You will be able to write:

```ruby
it { should have_run('pwd') }
```

It's way more readable.

Now, you can start your first `context`:

```ruby
context "when running my:command" do
  before do
    @configuration.find_and_execute_task('my:command')
  end

  it { should have_run('echo "Hello, World!"') }
end
```

A `context` block always starts with either `When` or `With`, and should
describe one feature in a given context. In this context, we try to find and
execute the task `my:command` and ensure it has run `echo "Hello, World!"`.

If this task takes parameters like a `:name` variable, you should write a new
`context` to test it. The `@configuration` object has all its methods available
in your recipe. You can call the `set` method to change a parameter:

```ruby
context "when running my:command" do
  before do
    @configuration.set :name, "John"
    @configuration.find_and_execute_task('my:command')
  end

  it { should have_run('echo "Hello, John!"') }
end
```

Other matchers are available like `have_gotten` or `have_uploaded` depending on
what you need. Look at the [capistrano-spec README][capistrano-spec] for more
information (it also contains useful examples). That's all folks!

## Links

- [Better Specs](https://www.betterspecs.org/): RSpec guidelines with Ruby
- [capistrano-spec](https://github.com/mydrive/capistrano-spec): helpers and
  matchers for testing capistrano recipes
- [capifony specs](https://github.com/everzet/capifony/tree/master/spec): the
  capifony test files

[bundler]: https://bundler.io/
[bundler-rubygems]: https://bundler.io/rubygems.html
[capistrano]: https://github.com/capistrano/capistrano
[capistrano-spec]: https://github.com/mydrive/capistrano-spec
[post-capifony]: {% post_url 2012-06-22-capifony-the-cool-capistrano-recipes-for-symfony-applications %}
[rake]: https://ruby.github.io/rake/
[rspec]: https://rspec.info/