---
layout: post
title: Testing Capistrano Recipes For Dummies
location: Clermont-Fd Area, France
---

A couple months ago, I [took the lead of
capifony](2012-06-22-capifony-the-cool-capistrano-recipes-for-symfony-applications),
a set of [Capistrano](https://github.com/capistrano/capistrano) recipes for
[Symfony2](http://symfony.com) projects. I tried to revamp the project, and
one of my goals was to add tests. This article sums up my work on that topic.


## Making your recipe testable

In order to make a Capistrano recipe testable, a common practice is to create a
module that can extends a Capistrano configuration instance:

{% highlight ruby %}
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
{% endhighlight %}

The last three lines are needed to keep the original behavior of your recipe,
assuming you have an existing recipe that doesn't follow this practice.

You are ready to test your recipe, but _how?_
[capistrano-spec](https://github.com/mydrive/capistrano-spec) to the rescue!
**capistrano-spec** integrates [RSpec](http://rspec.info/) into the Capistrano
world so that you can easily test your recipes. It has been created by [Josh
Nichols](https://github.com/technicalpickles).


### Installing capistrano-spec

The first step is to create a `spec/spec_helper.rb` file used to load everything
to run your tests. This file looks like:

{% highlight ruby %}
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
{% endhighlight %}

As you may noticed, [Bundler](http://gembundler.com/) is used to manage our
dependencies. The `Gemfile` file should contain:

{% highlight ruby %}
source 'http://rubygems.org'

gemspec

gem 'rake'
gem 'rspec'
gem 'capistrano-spec', :git => 'git://github.com/mydrive/capistrano-spec.git'
{% endhighlight %}

`gemspec` loads all dependencies located in the `.gemspec` file, used to build your
_gem_. For more information, please read [Using Bundler with Rubygem
gemspecs](http://gembundler.com/rubygems.html).

Also, a best practice here is to rename your `Gemfile` to `.gemfile` as
it's used for testing purpose only. It's not a big deal though, it just makes
your project a bit cleaner.

Run the command below to install your dependencies:

    BUNDLE_GEMFILE=.gemfile bundle install

You also need a `Rakefile` file to configure [Rake](http://rake.rubyforge.org/).
It is similar to `make` and allows you to run a set of tasks. In order to run
your examples, you need a `spec` task. The following snippet is all you need:

{% highlight ruby %}
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = '--color --format=documentation -I lib -I spec'
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
{% endhighlight %}

Now, you probably want to write your first test, and you are right!


## Writing your first test

Create a new file named `spec/my_recipe_spec.rb` and add the content below:

{% highlight ruby %}
require 'spec_helper'

describe "MyRecipe" do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)

    MyRecipe.load_into(@configuration)
  end

  # Your code here
end
{% endhighlight %}

As you can see, we create a Capistrano configuration instance, and we extend it
with capistrano-spec. This configuration instance is injected into our module.

Try to run the `spec` task using the following command:

    BUNDLE_GEMFILE=.gemfile bundle exec rake spec

You should see:

    Finished in 0.00006 seconds
    0 examples, 0 failures

If everything looks good, congratulations! Time to write your **examples**. Yes,
in Rspec, you don't really write tests, you write **executable examples** of the
expected behavior of your code.

First, declare the `@configuration` variable as subject:

{% highlight ruby %}
subject { @configuration }
{% endhighlight %}

It tells RSpec what we are doing the tests on. Instead of writing something
like:

{% highlight ruby %}
it { @configuration.should have_run('pwd') }
{% endhighlight %}

You will be able to write:

{% highlight ruby %}
it { should have_run('pwd') }
{% endhighlight %}

It's way more readable.

Now, you can start your first `context`:

{% highlight ruby %}
context "when running my:command" do
  before do
    @configuration.find_and_execute_task('my:command')
  end

  it { should have_run('echo "Hello, World!"') }
end
{% endhighlight %}

A `context` block always starts with either `When` or `With`, and should
describe one feature in a given context. In this context, we try to find and
execute the task `my:command`, and to ensure it has run `echo "Hello, World!"`.

If this task has some parameters, like a `:name` variable, you should write a
new `context` to test it. The `@configuration` object has all methods available
in your recipe, so you can call the `set` method to change a parameter:

{% highlight ruby %}
context "when running my:command" do
  before do
    @configuration.set :name, "John"
    @configuration.find_and_execute_task('my:command')
  end

  it { should have_run('echo "Hello, John!"') }
end
{% endhighlight %}

Other matchers are available like `have_gotten`, or `have_uploaded` depending on
what you need. Look at the
[capistrano-spec readme](https://github.com/mydrive/capistrano-spec#testing) for more
information, it also contains useful examples. That's all folks.


## Links

* [Better Specs](http://betterspecs.org/): rspec guidelines with ruby;
* [capistrano-spec](https://github.com/mydrive/capistrano-spec): helpers and
matchers for testing capistrano;
* [capifony specs](https://github.com/everzet/capifony/tree/master/spec): the
capifony source code.
