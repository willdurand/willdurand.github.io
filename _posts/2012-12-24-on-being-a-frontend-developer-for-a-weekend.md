---
layout: post
title: On being a frontend developer for a weekend
location: Clermont-Fd Area, France
updates:
  - date: 2023-04-14
    content: I proofread this article and fixed some links.
redirect_from:
  - /2012/12/24/being-a-frontend-developer-for-a-weekend/
---

Two weeks ago, I open-sourced
[TravisLight](https://github.com/willdurand/TravisLight), a build monitoring
tool – also known as a _build wall_ – for [Travis-CI](https://travis-ci.org/).
That was a weekend project I did for fun but also to embrace frontend
development.

When I was at Nelmio, I was mainly a backend dev, even though I worked on some
JavaScript stuff. I spent most of my time writing APIs for the frontend
developers, not JavaScript apps. That needed to change!

## The beginning

I started to read Backbone Fundamentals as I wanted to learn
[Backbone.js](https://backbonejs.org/). Backbone.js is a JavaScript framework
that offers a structure to write a web application.

Since working on a project is the best way to learn, I decided to write a
Backbone.js application using the Travis-CI API. TravisLight – the project I
developed over a weekend – was something I always wanted in order to manage my
own open source projects. I needed a tool that was simple and clear. That was
the perfect project to start, especially for a weekend!

Instead of using [Underscore.js](https://underscorejs.org/), I used
[Lo-Dash](https://lodash.com/), an alternative to Underscore.js delivering
consistency, customization, performance, and extra features as they say. I also
used [RequireJS](https://requirejs.org/) and [Moment.js](https://momentjs.com/).
In order to manage all these dependencies, I needed a tool: Bower (from Twitter)
looked like the right tool.

## Bower, a package manager for the web

[Bower](https://github.com/twitter/bower) is a package manager for the web (i.e.
for JS/CSS libraries). Even if it is more a package downloader for now, it's
worth using it to avoid putting libraries in git directly.

Bower relies on a `component.json` file that looks like this:

```json
{
  "name": "travis-light",
  "dependencies": {
    "jquery": "~1.8.3"
  }
}
```

Running `bower install` will install the dependencies into a `components/`
folder. To add a new library, we can run `bower install <lib> --save` to install
it. This command will also update the `component.json` file automatically.

At the beginning of the development phase, I needed a tool to perform some tasks
on my application like running [jshint](https://www.jshint.com/) or compiling my
files. I tried Grunt, a build tool written in JavaScript, and it turned out to
be a good choice.

## Grunt, the JavaScript build tool

[Grunt](https://gruntjs.com/) is a task-based command line build tool for
JavaScript projects. At first glance, this tool seems hard to use but once you
get it, it's magic! You can _lint_ your files, _minify_ your JS/CSS files, _run_
the test suite, and so on.

In TravisLight, I mainly used Grunt to package the application. This includes:

- compiling the JavaScript files
- compiling the CSS files
- using the compiled files into the HTML markup
- copying the required libraries

Thanks to the
[grunt-contrib-requirejs](https://github.com/gruntjs/grunt-contrib-requirejs)
plugin, compiling the JavaScript files is straightforward:

```json
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
```

Compiling the CSS files in TravisLight is a two-step task. First, all the images
in the CSS have to be embedded using the
[grunt-image-embed](https://github.com/ehynds/grunt-image-embed) plugin:

```json
imageEmbed: {
  application: {
    src: 'css/application.css',
    dest: 'dist/application-embed.css',
    deleteAfterEncoding : false
  }
}
```

Then, the CSS files are minified using the
[grunt-contrib-mincss](https://github.com/gruntjs/grunt-contrib-mincss/) plugin:

```json
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
```

At this point, the last task is compiling the HTML to use the JS and CSS
compiled files. This is achieved by using the
[grunt-targethtml](https://github.com/changer/grunt-targethtml) plugin:

```json
targethtml: {
  dist: {
    src: 'index.html',
    dest: 'dist/index.html'
  }
}
```

The `index.html` file looks like:

```html
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
```

`target dummy` (the default) loads the code in development. This is a nice way
to keep a single HTML file with the ability to switch from development to
production (or whatever environment you want). That was an issue I was unable to
solve until I found this plugin!

Last but not least, the
[grunt-contrib-copy](https://github.com/gruntjs/grunt-contrib-copy/) plugin is
used to copy some important files to the `dist/` folder (which is where the
final build of the application is located):

```json
copy: {
  dist: {
    files: {
      'dist/js/require.js': 'components/requirejs/require.js'
    }
  }
}
```

Running `grunt package` performs all these tasks. See the TravisLight's
[grunt.js](https://github.com/willdurand/TravisLight/blob/master/grunt.js) file
for more details, especially the aliases.

With a great build system and lots of code written already, I needed to write
tests so I looked at some of the existing JavaScript testing libraries. I
already knew [QUnit](https://qunitjs.com/) but I wanted to use something
different. I ended up using [Mocha](https://mochajs.org/) and
[Chai](https://chaijs.com/).

## Testing a Backbone.js application

In the JavaScript world, there are plenty of testing libraries such as
[QUnit](https://qunitjs.com/), [Mocha](https://mochajs.org/), Jasmine,
[Chai](https://chaijs.com/), [Sinon.js](https://sinonjs.org/),
[Expect.js](https://github.com/Automattic/expect.js),
[Should.js](https://github.com/tj/should.js), and a lot more that I probably
don't even know.

As I wrote before, I used Mocha and Chai. These libraries can be installed using
[npm](https://npmjs.org/) (the [Node.js](https://nodejs.org/) package manager).
This tool uses a `package.json` file to define both the "normal" and "dev"
dependencies:

```json
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
```

A `node_modules/` directory contains the different packages specified in this
`package.json` file and installed by running `npm install`.

From there, I created a new file (`test/index.html`) that executes the test
suite in a browser:

```html
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
```

First, Mocha and Chai are loaded, followed by jQuery and RequireJS. Then, a
`setup.js` file is loaded. It contains the Mocha and RequireJS configurations as
well as two global variables (`assert` and `expect`) that are used in the test
files:

```json
var assert = chai.assert,
expect = chai.expect;

mocha.setup({
  ui: 'bdd'
});

require.config({
  baseUrl: '../js/',
  ...
});
```

I decided to follow the Behavior Driven Development style but this isn't
mandatory. Here is an example of a test file for the TravisLight's `router`:

```json
define([
  'router'
], function (router) {
  "use script";

  describe('router', function () {
    it('should be an instance of Backbone.Router', function () {
      expect(router).to.be.an.instanceOf(Backbone.Router);
    });

    it('should have a routes property', function () {
      expect(router.routes).to.be.an('object');
    });
  });
});
```

You will find more tests in this [`test/`
directory](https://github.com/willdurand/TravisLight/tree/master/test).

Achievement unlocked! I wrote a JavaScript application that is tested.

## Using Travis-CI with JavaScript projects

I am a big fan of [Travis-CI](https://travis-ci.org/) and I wanted to put
TravisLight on it. Thanks to Grunt, it couldn't be easier!

The [grunt-mocha](https://github.com/kmiyashiro/grunt-mocha) plugin allows to
use Mocha and [PhantomJS](https://phantomjs.org/) to run a test suite. Here is
the TravisLight's configuration for this plugin:

```json
mocha: {
  all: [ 'test/index.html' ]
}
```

A simple `grunt mocha` runs the test suite using PhantomJS (a headless browser):

    $ grunt mocha
    Running "mocha:all" (mocha) task
    Testing index.html...................OK
    >> 19 assertions passed (0.14s)

    Done, without errors.

Not bad, right? However, Travis-CI needs to be configured with a `.travis.yml`
file. JavaScript projects have to use the `node_js` environment on Travis-CI
and the application requires a set of libraries installed with Bower.

```yaml
language: node_js

node_js:
  - 0.8

before_script:
  - export PATH=\$PATH:`npm bin`
  - bower install
```

Travis-CI automatically runs `npm install` and `npm test`. This second command
is configured in the `package.json` file:

```json
{
  ...

  "scripts": {
    "test": "./node_modules/grunt/bin/grunt test"
  }
}
```

## The end

I sincerely enjoyed this weekend project. Working on a real project, even a
small one like TravisLight, allowed me to discover new things and understand a
bit better what it is like to be a frontend developer.

I also kinda felt in love with the JavaScript community. There is a lot of
awesome libraries and frameworks these days! Great stuff, looking forward to
writing more JavaScript in the future.
