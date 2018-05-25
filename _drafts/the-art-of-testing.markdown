---
layout: post
title: "The Art of Testing"
audio: false
tldr: false
location: "Freiburg, Germany"
---

I started programming ~10 years ago as a student. In 2010, I discovered two
things about me, professionally speaking: I liked to write web applications, and
writing tests was not only helpful but crucial.

<blockquote class="no-before-icon twitter-tweet" lang="en"><p>I don&#39;t need tests: tests are for people who write bugs.</p>&mdash; Hipster Hacker (@hipsterhacker) <a href="https://twitter.com/hipsterhacker/statuses/396352411754717184">November 1, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Around that time, testing was not as widespread as nowadays. It was quite the
opposite and we had to fight to introduce tests in a project. Usually, software
testing was seen as a completely different task, like a low priority feature.
For many people, especially non-developers, it was a "nice-to-have", but tests
were definitely not belonging to a feature. We do not deploy tests in production
after all! Thankfully, we now know that testing is part of the developer's job
(documentation too by the way), and many organizations believe in testing and
its benefits.

I have been lucky to get interested in testing very early in my career, in part
because I had good teachers/mentors and also because I was not good enough to
write code that worked well. For me, testing was (and still is) a way to think
about the problems I was trying to solve and helped me a lot in breaking them
into smaller chunks. I often did [test-driven
development](https://en.wikipedia.org/wiki/Test-driven_development) when I had
no idea on how to come up with an algorithm but I knew the outcomes.

I have written tests in many different languages over the last 8 years, I wrote
unit tests, functional tests, integration tests, end-to-end tests, _etc._ I even
did a PhD about formal testing applied to industrial systems. While I consider
myself knowledgeable about software testing, I am not an expert and I learn new
things about this topic regularly.

Lately, many people with different backgrounds asked for advices and resources
on how to start writing tests. This made me realize that we can find a lot of
documentation on how to write tests for a specific language, use case, layer,
and so on, but I did not find any good material on how to get started when you
almost never wrote any test case before.

Wait, what is a "test case" actually? Also, what is a "test suite"? What does it
mean to write "unit" tests? And what is a "mock"? I am going to explain all of
these terms from the ground up in a simple yet accurate manner.

## Are we building the right software?

> Testing can prove confidence of a software system by executing a program with
> the intent of finding errors. – _Glenford J. Myers_

First of all, we often write tests to validate some characteristics of an
application and the game is to come up with as much (edge) cases as possible. We
have to do this because testing shows the presence, not the absence of bugs
(synonyms: faults, errors or defects) as [Edsger Wybe Dijkstra used to
say](http://homepages.cs.ncl.ac.uk/brian.randell/NATO/nato1969.PDF). This is
important for, at least, two reasons:

- it is very difficult to write software that are completely free of defects,
  and it should not even be the goal. Rather, your application must be good
  enough for its intended use;
- we want to write multiple tests for a single part of an application because it
  can have bugs depending on how we call that part for instance.

In general, testing involves a (software) system under test (SUT), which is the
application you are working on. You have to know this term because it is used
sometimes. The prevailing intuition of testing is reflected in its operational
characterization as an activity in which a tester first generates and sends
stimuli, _i.e._ test input data, to a system under test in order to observe
phenomena (mainly behaviors). Such phenomena can be represented by the existence
of test outputs for instance, like the result of a function call. We then have
to decide on a suitable verdict, which expresses the assessment made (does this
result make sense?).

The two most well-known verdicts are **Pass** and **Fail**. That is why you can
read or hear: _"tests fail"_ or _"the build passes"_, and because we often use
colors (green and red, respectively), we also say _"the build is green"_ or
_"the tests are red"_. The term "build" refers to the notion of Continuous
Integration (CI), a way to automatically run the tests (often _via_ a
third-party service, _e.g._, [Travis CI](https://travis-ci.org/)).

We call **test case**, a structure that is compound of test data, _i.e._ inputs
which have been devised to test the system, an **expected behavior**, and an
expected output. That is what you will have to write, many times. Last but not
least, a set of test cases is called a **test suite**.

To summarize, what we often call "tests" in a project are either some "test
cases" or the "test suite". It does not matter whether you talk about unit or
integration tests, but wait a minute... What is a "unit test" or an "integration
test"?

## Types of testing

There are different types of testing, just like there are different chocolates:
the [couverture chocolate](https://en.wikipedia.org/wiki/Couverture_chocolate)
is used for cooking while the 75% dark chocolate is usually eaten directly. Both
are really good, can look the same and are made of cacao, but they have
different purposes.

You will find a lot of terms that all end with "testing" such as: unit testing,
integration testing, functional testing, system testing, stress testing,
performance testing, usability testing, acceptance testing, regression testing,
beta testing, and so on. There are various ways to categorize them, but we often
classify the different techniques based on the target of the test (sometimes we
refer to this classification as level of detail or phase) as listed below:

- Unit testing: individual units (_e.g._, functions, methods, modules) or groups
  of related units of the system are tested in isolation. Typically this
  testing type implies access to the source code being tested;
- Integration testing: interactions between software components are tested.
  Functional tests fall into this category. Remember the term "continuous
  integration" before? It is very related because this type of testing is a
  continuous task;
- System testing: the whole system is taken into consideration to evaluate the
  system's compliance with its specified requirements. This testing type is also
  appropriate for validating not-only-functional requirements, such as security,
  performance (speed), accuracy, and reliability (fault tolerance).

We are going to skip the last type of testing (system) in this blog post, and
functional tests will not be extensively covered either. There are great tools
to write functional tests to mimic user (or business-oriented) scenarios and run
these tests in different environments (different web browsers for example). The
challenge of writing functional tests is to write robust tests:

- Functional tests should describe real life scenarios, which is time-consuming
  and tedious. Such tests also require a lot of maintenance to keep them
  synchronized with the application. If you change the position of the submit
  button, you do not expect your tests to fail if the button is still there;
- Functional tests rely on a complete test environment, often requiring other
  services (_e.g._, a database, a mailer or the filesystem), but also test
  fixtures (application data generated for testing purpose) and, in the context
  of web applications, a browser. Each of these new dependencies can break for
  some reason, making your functional test suite flaky.

Let's focus on unit tests now. Unit tests should be simple tests, focused on one
and only one use case (behavior), and fast (in terms of execution speed). That
makes them difficult to write because as soon as you will know how to write
these tests and what you can do to ease your developer's life (using "mocks" for
instance), you will likely write bad unit tests (I did that many times).

## How to write tests?

To be honest, writing good (unit) tests is difficult because it is something you
have to learn... by writing tests. While I explicitly said that I would focus on
unit tests, the upcoming principles apply to any type of testing.

In order to write tests, you have to learn two different things: (1) the theory
on how to write great test cases, and (2) the syntax, depending on the project
and the testing framework in use.

The good thing about the latter is that most testing frameworks are similar to
the [xUnit frameworks](https://en.wikipedia.org/wiki/XUnit), the most well-known
tools for writing tests in most programming languages
([PHPUnit](https://phpunit.de/), [JsUnit](http://www.jsunit.net/),
[JUnit](https://junit.org/),
[CppUnit](https://freedesktop.org/wiki/Software/cppunit/),
[NUnit](http://nunit.org/), ...). Note that new testing frameworks appeared over
the last five years though, mainly to improve expressiveness and have a better
experience writing tests (with new syntax, helper functions and speed
improvements for instance).

Let's concentrate on how to write test cases now. According to the definition of
a test case given previously, we need something to test (SUT), some input data
and a way of determining whether the resulting output or behavior is expected or
not. This is what we call an expectation, and every test case should have at
least one. We validate these expectations with assertions.

An assertion is a statement that a true–false expression is always true at that
point in code execution, [according to
Wikipedia](https://en.wikipedia.org/wiki/Assertion_(software_development)). When
you expect an addition function `add(a, b)` to return `2` given `1` and `1` as
inputs, the assertion is: the value returned by `add(1, 1)` must be equal to
`2`. Many test frameworks use the keyword `assert` to help you write these
assertions. For example, you could write the following Python code:

```python
# Python

assert add(1, 1) == 2
```

You might also find more expressive keywords such as `expect` followed by a
"matcher", a function that tests the expected value in a certain way. For
instance, we could write the code below with
[Jest](https://facebook.github.io/jest/), a JavaScript testing framework:

```js
// JavaScript

expect(add(1, 1)).toEqual(2);
```

In Java with JUnit, you would probably write the code below:

```java
// Java

assertThat(add(1, 1), is(2));
```

As you can see, the same assertion is expressed in slightly different ways, but
in the end, the expectation remains the same. You will have to learn how to
write these assertions depending on your project. When writing a test case, you
should have clear expectations in mind, and that starts with knowing the purpose
of this test case. Most testing frameworks will give you a minute to think about
it, because you will have to write a test case method or function and give a
name or description to that test case. You should never neglect this part
because your tests should be understandable and have objectives.

Continuing my example with the `add()` function, you could write a test case
with a name like `test_ok()` or `"it works"` but that is not meaningful at all.
What you should write instead is the intent/purpose of this test case. You
should find a description or method name that is both short and accurate. In the
two code snippets below, I try to convey the intent of the test case (_i.e._ my
expectation), which is then highlighted by the assertion.

```python
# Python

def test_add_returns_positive_integer():

  assert add(1, 1) == 2
```

```js
// JavaScript

test('add() returns a positive integer when called with two positive integers', () => {
  expect(add(1, 1)).toEqual(2);
});
```

Most xUnit frameworks require a `test` prefix on the test case function/method
(or a `@Test` annotation) so that the runner finds the test cases to execute,
but other frameworks offer, again, a slightly different syntax (as seen above).
The runner is an important part of any testing framework. Its job is to find all
the test cases in your project, to run them, and to generate a report for you.
Great testing frameworks have great runners (and a very expressive syntax).

It is OK to have more than one assertion, as far as the assertions are related
to the same expectation. If you find yourself writing assertions for a different
expectation, it would be better to write another test case. This happens often
when the piece of code you are testing does different things for instance.

describe/it: writing good test case descs

```
run the test suite/make a change/run the test suite
regressions
think about all the edge cases
future-proof tests
```

## About test doubles

...

* **Dummy** objects are passed around but never actually used. Usually they are
  just used to fill parameter lists;
* **Fake** objects actually have working implementations, but usually take some
  shortcut which makes them not suitable for production (an in memory database
  is a good example);
* **Stubs** provide canned answers to calls made during the test, usually not
  responding at all to anything outside what's programmed in for the test. Stubs
  may also record information about calls, such as an email gateway stub that
  remembers the messages it 'sent', or maybe only how many messages it 'sent'
  &rarr; **State verification**;
* **Mocks** are objects pre-programmed with expectations which form a
  specification of the calls they are expected to receive &rarr; **Behavior
  verification**.

...
