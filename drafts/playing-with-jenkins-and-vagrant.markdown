---
layout: post
title: Playing With Jenkins And Vagrant
location: Clermont-Fd Area, France
---

Lately, I focused my free time on improving my skills related to continuous
integration processes. You may know [Travis CI](http://travis-ci.org/), a hosted
CI service for open source projects. Travis basically creates a new virtual
machine with a given configuration for each build. This strategy ensures to
always run a test suite against the same environment, let me explain.


## Running tests against the same environment

Continuous testing your project implies to run your test suite in a given
environment, and to always use the same. That way, you can track regressions.

This is really useful and thanks to Travis, it's really easy. Basically, you get
a working VM with common tools and you configure a set of commands to configure
the VM once booted.

_Example: if I want to test a PHP project, I will get a VM with PHP installed,
and my project cloned in the working directory. In this project, I will define
commands like `composer install` to install the project's dependencies. Once
dependencies are installed, I just have to run `phpunit`, just like I would do
on my machine. Pretty straightforward._

Travis is perfect for open source projects and when you just need a CI server to
run tests. However, tools like [Jenkins](http://jenkins-ci.org/) are able to
perform more operations. So it could be nice to know how to reproduce the same
strategy using Jenkins.


http://stackoverflow.com/questions/9150732/capistrano-deploy-in-virtual-machne
https://github.com/mitchellh/vagrant/issues/713
http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
