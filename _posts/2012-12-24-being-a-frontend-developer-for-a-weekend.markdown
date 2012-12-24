---
layout: post
title: Being A Frontend Developer For A WeekEnd
location: Clermont-Fd Area, France
audio: false
---

Two weeks ago, I open-sourced
[TravisLight](http://williamdurand.fr/TravisLight/), a build monitoring tool,
also known as _buildwall_, for [Travis-CI](https://travis-ci.org/). That was a
weekend project I did for fun, but also to act as a real frontend developer.

When I was at [Nelmio](http://nelm.io), I was more a backend guy than a frontend
developer, even if I worked on some of the JavaScript applications. I spent most
of my time writing APIs for the frontend developers, but sometimes I was just
wrong. Actually, I think every backend guy should work on frontend stuff for a
while, and vice versa. That's one of the best ways to understand what you need
to do.

I noticed that **the only things a frontend developer needed** was a **smart
API**, and a **good documentation**. As a backend developer, you have to provide
both. **The frontend developer depends on you**.
Also, don't force your frontend guy to use your tools. Yeah,
[Assetic](https://github.com/kriswallsmith/assetic) is a wonderful toy for PHP
developers, but it's not a tool for frontend guys. There are better tools to
compile the JS/CSS files, written in JavaScript, like
[Grunt](http://gruntjs.com/). **Let your frontend developer manage his own
stuff**. For example, in a Symfony2 project, I would recommend to put all JS/CSS
files into the `web/` folder rather than into the `*Bundle/Resources/public`
folders, so that the frontend guy doesn't have to browse the whole project to
find a specific file.

But this is not the purpose of this post. Let me explain why and how I wrote
TravisLight, and the tools I discovered.


## The Beginning

I started reading [Backbone
Fundamentals](http://addyosmani.github.com/backbone-fundamentals/) as I
wanted to learn [Backbone.js](http://backbonejs.org/). If you don't know
Backbone yet, it's a JavaScript framework that gives you a structure to write a
web application.

As working on a project is the best way to learn, I decided to write a
Backbone.js application using the [Travis-CI
API](https://api.travis-ci.org/docs/).
TravisLight was something I always wanted in order to manage my own open source
projects. I needed a tool that was simple and clear. That was the perfect project
to start, especially for a weekend.

Instead of using [Underscore.js](http://underscorejs.org/), I used
[Lo-Dash](http://lodash.com/) which is an alternative to Underscore.js
delivering consistency, customization, performance, and extra features as they
say. I also used [RequireJS](http://requirejs.org/), and
[Moment.js](http://momentjs.com/). In order to manage all these dependencies,
I needed a tool, so I took a look at Bower, from the Twitter guys.


## Bower, A Package Manager For The Web

[Bower](https://github.com/twitter/bower) is a package manager for the web, in
other words, a package manager for JS/CSS libraries. Even if it's more
a package downloader for now, it's worth using it to avoid versioning
[jQuery](http://jquery.com/), [Twitter
Bootstrap](http://twitter.github.com/bootstrap/), etc. All you need is a
`component.json` file that looks like:

{% highlight json %}
{
  "name": "travis-light",
  "dependencies": {
    "jquery": "~1.8.3"
  }
}
{% endhighlight %}

Running `bower install` installs the dependencies into a `components/` folder.

So, I started to work hard on my application. Each time I needed a new library,
I ran `bower install <lib> --save` to install it and update the `component.json`
file.

At some point, I needed a tool to perform some tasks on my application like
running [jshint](http://www.jshint.com/) or compiling my files. I tried
Grunt, a build tool written in JavaScript, and it was a good choice.


## Grunt, The JavaScript Build Tool

[Grunt](http://gruntjs.com/) is a task-based command line build tool for
JavaScript projects. At first glance, this tool seems hard to use, but once you
get it, it's just awesome! You can _lint_ your files, _minify_ your JS/CSS
files, _run_ the test suite, and so on.

In TravisLight, I mainly use Grunt to package the application. Packaging the
application means:

* compiling the JavaScript files;
* compiling the CSS files;
* using the compiled files into the HTML markup;
* copying the required libraries.

Compiling the JavaScript files is about compiling the
[RequireJS](http://requirejs.org/) dependencies. Thanks to the
[grunt-contrib-requirejs](https://github.com/gruntjs/grunt-contrib-requirejs)
plugin, it's super easy!

{% highlight javascript %}
requirejs: {
    compile: {
        options: {
            name: "main",
            baseUrl: "js/",
            mainConfigFile: "js/main.js",
            out: "dist/compiled.js"
        }
    }
}
{% endhighlight %}

Compiling the CSS files in TravisLight is a two-step action. First, all images
in the CSS are embedded using the
[grunt-image-embed](https://github.com/ehynds/grunt-image-embed) plugin:

{% highlight javascript %}
imageEmbed: {
    application: {
        src: 'css/application.css',
        dest: 'dist/application-embed.css',
        deleteAfterEncoding : false
    }
}
{% endhighlight %}

Then, the CSS files are minified using the
[grunt-contrib-mincss](https://github.com/gruntjs/grunt-contrib-mincss/) plugin:

{% highlight javascript %}
mincss: {
    compress: {
        files: {
            'dist/compiled.css': [
                'css/bootstrap.min.css',
                'dist/application-embed.css'
            ]
        }
    }
}
{% endhighlight %}

Now, I just have to compile the HTML to use these compiled JS and CSS files.
It's achieved by using the
[grunt-targethtml](https://github.com/changer/grunt-targethtml) plugin:

{% highlight javascript %}
targethtml: {
    dist: {
        src: 'index.html',
        dest: 'dist/index.html'
    }
}
{% endhighlight %}

The `index.html` file looks like:

{% highlight html %}
<!doctype html>
<html lang="en">
    ...

    <body data-api-url="https://api.travis-ci.org">
        <!--(if target dist)>
        <script data-main="compiled" src="js/require.js"></script>
        <!(endif)-->
        <!--(if target dummy)><!-->
        <script data-main="js/main" src="components/requirejs/require.js"></script>
        <!--<!(endif)-->
    </body>
</html>
{% endhighlight %}

`target dummy` is the default piece of code, used in development. This is a nice
way to keep a single HTML file with the ability to switch from development to
production (or whatever environment you want).
That was an issue I was unable to solve until I found this plugin.

Last but not the least, the
[grunt-contrib-copy](https://github.com/gruntjs/grunt-contrib-copy/) plugin
is the one I used to copy some files to the `dist/` folder:

{% highlight javascript %}
copy: {
    dist: {
        files: {
            'dist/js/require.js': 'components/requirejs/require.js'
        }
    }
}
{% endhighlight %}

Running `grunt package` performs all these tasks. See the TravisLight's
[grunt.js](https://github.com/willdurand/TravisLight/blob/master/grunt.js) file
for more details, especially the aliases.

At this moment, I had a JavaScript application that worked for me™. So, I looked
at some JavaScript testing libraries. I already knew
[QUnit](http://qunitjs.com/) but I wanted to use something different so I gave a
try to [Mocha](http://visionmedia.github.com/mocha/) and
[Chai](http://chaijs.com/).


## Testing A Backbone.js Application

In the JavaScript world, there are plenty testing libraries such as
[QUnit](http://qunitjs.com/), [Mocha](http://visionmedia.github.com/mocha/),
[Jasmine](http://pivotal.github.com/jasmine/), [Chai](http://chaijs.com/),
[Sinon.js](http://sinonjs.org/),
[Expect.js](https://github.com/LearnBoost/expect.js),
[Should.js](https://github.com/visionmedia/should.js), and a lot more.

I tried Mocha and Chai. These libraries can be installed using
[NPM](https://npmjs.org/), the [Node.js](http://nodejs.org/) package manager.
NPM needs a `package.json` file with the list of the project's dependencies, and
the _dev_ dependencies:

{% highlight json %}
{
  "name": "TravisLight",
  "version": "0.0.1",
  "dependencies": {
  },
  "devDependencies": {
    "mocha": "~1.7.4",
    "chai": "~1.4.0"
  }
}
{% endhighlight %}

Running `npm install` installs both Mocha and Chai in the `node_modules/`
directory.

Now, you need a `test/index.html` file to run the test suite in a browser:

{% highlight html %}
<html>
    <head>
        <meta charset="utf-8">
        <title>TravisLight Test Suite</title>
        <link rel="stylesheet" href="../node_modules/mocha/mocha.css" />
    </head>
    <body>
        <div id="mocha"></div>
        <script src="../node_modules/chai/chai.js"></script>
        <script src="../node_modules/mocha/mocha.js"></script>
        <script src="../components/jquery/jquery.min.js"></script>
        <script src="../components/requirejs/require.js"></script>
        <script src="setup.js"></script>
        <script>
            require(
                [
                    '../test/router.test',
                ],
                function () {
                    mocha.run();
                }
            );
        </script>
    </body>
</html>
{% endhighlight %}

First, Mocha and Chai are loaded, followed by jQuery and RequireJS. Then, a
`setup.js` file is loaded. It contains the Mocha and RequireJS configurations,
and two global variables `assert` and `expect` that will be used in the test
files:

{% highlight javascript %}
var assert = chai.assert,
    expect = chai.expect;

mocha.setup({
    ui: 'bdd'
});

require.config({
    baseUrl: '../js/',

    ...
});
{% endhighlight %}

I decided to follow the **BDD** style, but it's just a matter of taste.
Here is an example of test file for the TravisLight's `router`:

{% highlight javascript %}
define(
    [
        'router'
    ],
    function (router) {
        "use script";

        describe('router', function () {
            it('should be an instance of Backbone.Router', function () {
                expect(router).to.be.an.instanceOf(Backbone.Router);
            });

            it('should have a routes property', function () {
                expect(router.routes).to.be.an('object');
            });
        });
    }
);
{% endhighlight %}

You can look at the [`test/`
directory](https://github.com/willdurand/TravisLight/tree/master/test) for more
information.

Achievement unlocked! I wrote a JavaScript application that is tested.


## Using Travis-CI With JavaScript Projects

I am a big fan of [Travis-CI](https://travis-ci.org/), and I wanted to put
TravisLight on it. Thanks to Grunt, it couldn't be easier!

The [grunt-mocha](https://github.com/kmiyashiro/grunt-mocha) plugin allows to
use Mocha and [PhantomJS](http://phantomjs.org/) to run a test suite. Here is
the TravisLight's configuration for this plugin:

{% highlight javascript %}
mocha: {
    all: [ 'test/index.html' ]
}
{% endhighlight %}

A simple `grunt mocha` runs the test suite using PhantomJS:

    $ grunt mocha
    Running "mocha:all" (mocha) task
    Testing index.html...................OK
    >> 19 assertions passed (0.14s)

    Done, without errors.

Not bad. However, Travis-CI needs to be configured using a `.travis.yml` file.
JavaScript projects have to use the `node_js` environment on Travis-CI, and the
application requires a set of libraries installed through Bower:

{% highlight yaml %}
language: node_js

node_js:
    - 0.8

before_script:
    - export PATH=$PATH:`npm bin`
    - bower install
{% endhighlight %}

Travis-CI will run `npm install` first, and then `npm test`. This second command
has to be configured in the TravisLight's `package.json`:

{% highlight json %}
{
  ...

  "scripts": {
    "test": "./node_modules/grunt/bin/grunt test"
  }
}
{% endhighlight %}


## The End

I really enjoyed working as a frontend developer, and I am in love with the
JavaScript community. Nowadays, there are a lot of awesome libraries and
frameworks, and I won't have enough time to try them all.

I first named this blog post **JavaScript from the trenches**, as I decided to
learn everything I knew about JavaScript again. I never considered myself a
frontend developer, or a JavaScript developer. I too often meet people that
think JavaScript/CSS languages aren't worth learning as they think these
languages are dead simple. They are on the wrong path, I have huge respect for
the frontend guys I know, the real ones.

Generally speaking, I think working on frontend applications changed my mind
regarding APIs. Also, working on a real project, even a small one like
TravisLight, allows you to understand things faster than ever.
