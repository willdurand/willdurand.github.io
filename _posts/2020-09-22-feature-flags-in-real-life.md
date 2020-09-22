---
layout: post
title: "Feature flags in real life"
audio: false
tldr: false
location: "Freiburg, Germany"
image: /images/posts/2020/09/waffle.jpg
tweet_id:
---

Many folks are familiar with the concept of [feature
toggles](https://martinfowler.com/articles/feature-toggles.html) (also known as
_feature flags_) but they do not necessarily use them because &lt;insert reason
here&gt;. This is a very powerful technique that allows teams to ship new
features and/or experiments in a controlled way. My team uses different flavors
of feature toggles on the [AMO](https://addons.mozilla.org) platform, and that
is what I am going to describe in this article.

## Backend toggles

The AMO server-side is mainly powered by a Django application and we are using
[Waffle](https://waffle.readthedocs.io/) to implement the different feature
toggles. Waffle has three types of feature flippers: _flags_, _switches_ and
_samples_, depending on the needs. I am not very familiar with the last one,
which seems to be a better packaged version of `rand()`, so I'll only introduce
the first two flippers.

### Flags

[Flags](https://waffle.readthedocs.io/en/stable/types/flag.html) are probably
what most people have in mind when thinking about feature toggles. They are
convenient to roll out features according to various conditions, like specific
users or percentage of traffic.

My team uses flags to progressively enable new features in production. This can
be useful when the feature can only be fully tested in production, e.g., because
it is not possible to set up a realistic (enough) environment or it has privacy
implications. Flags can certainly be used for other purposes but I am mainly
familiar with these ones.

This is how I shipped the [new usage statistics on
AMO](https://blog.mozilla.org/addons/2020/06/10/improvements-to-statistics-processing-on-amo/)
to end users earlier this year for instance. That was handy to iterate quickly
and give early access to [Quality
Assurance](https://en.wikipedia.org/wiki/Quality_assurance) (QA) folks,
Project/Product Managers (PMs), and key users (in this case, developers of very
popular add-ons to measure the performance impacts). Later, we updated the flag
configuration to perform a rollout (25/50/75/100%). During this rollout, users
got access to a "beta mode" (the new feature I was working on) in addition to
the legacy feature but it does not have to be this way.

It is also possible to use a toggle to change a feature entirely for everyone,
and that is the strategy I used for the [download stats on
AMO](https://blog.mozilla.org/addons/2020/09/17/download-statistics-update/)
lately. This is useful to preview a feature without risking a production
incident :-)

### Switches

Being able to turn a feature on and off for everyone in production can also be
achieved by a
[switch](https://waffle.readthedocs.io/en/stable/types/switch.html). Switches
cannot target specific users or things like that, but it is what we use the most
on AMO.

For example, we have switches that act as [kill
switches](https://en.wikipedia.org/wiki/Kill_switch) to quickly react to
potential outages in production. Our kinda monolithic server-side application
talks to some smaller services and if one of them goes crazy, we can quickly
shunt it so that it does not take the entire platform down.

We also use switches to change parts of our application that run in the
background like cron jobs or asynchronous tasks. In the case of the new AMO
statistics, I used switches to change the data source of the tasks that compute
particular values (e.g., average daily users, etc.). After having tested the new
behavior in our non-production environments, we turned the switches on in
production at a given time and we monitored the first executions.

Similar to flags, switches are great to ship big features incrementally and
allow long periods of tests in non-production environments. That way, we can
detect and fix most issues early, preventing disasters when we are supposed to
go live.

## Frontend toggles

We do not have the exact same concept in our main frontend app, but we do have
some sort of client-side feature toggles. We came up [a
convention](https://github.com/mozilla/addons-frontend/issues/6362) to implement
switches on top of [node-config](https://github.com/lorenwest/node-config) and
[our very own client-side
implementation](https://github.com/mozilla/addons-frontend/blob/79b846383e639f51f6e78d989348c057e2bad203/src/core/client/config.js)
for it. We use frontend switches quite often so that QA can verify the changes
before they are deployed in production. In addition to that, we can start
conversations with PMs and [User
eXperience](https://en.wikipedia.org/wiki/User_experience) (UX) people while we
are implementing the changes.

Our feature flipper implementation may appear naive, it works great for us. We
shipped new pages, homepage redesigns, and other minor features behind such
switches. That being said, this approach is not as flexible as its server
equivalent because it requires a deployment to update the values of the
switches.

## How do we test our code?

Django Waffle stores its configuration in the database and provides [helper
functions](https://waffle.readthedocs.io/en/stable/testing/automated.html) to
create flags or switches in a test case. We usually write similar tests with the
feature toggle enabled and disabled.

Most of our frontend code is written with React. We use a pattern that consists
in passing a `_config` prop whose default value is the actual node config and we
override it in the test case with a fake config object. That way, we can unit
test all possible conditions:

```jsx
import config from 'config';

function Welcome({ _config = config } = {}) {
  return (
    <h1>Hello, {_config.get('enableFeatureXYZ') ? 'XYZ' : 'World'}</h1>
  );
}
```

```js
// test file
it('renders Hello, World when the XYZ feature is disabled', () => {
  const _config = getFakeConfig({ enableFeatureXYZ: false });
  expect(renderWelcome({ _config })).toHaveText('Hello, World');
});

it('renders Hello, XYZ when the XYZ feature is enabled', () => {
  const _config = getFakeConfig({ enableFeatureXYZ: true });
  expect(renderWelcome({ _config })).toHaveText('Hello, XYZ');
});
```

When adding a new behavior behind a toggle to an existing feature, we usually
update the test suite to work as before and we add new test cases for the new
behavior. This often implies the addition of very similar test cases but it is
not so bad as we always plan to delete some code later on.

## A note on code quality

Every time we introduce a Waffle flag, a switch or a frontend toggle, we file a
GitHub issue to clean up the code once there is no need for it anymore. If the
author forgets about it, this is usually raised during the code review. This is
how we mitigate the risk of having [spaghetti
code](https://en.wikipedia.org/wiki/Spaghetti_code). Some toggles (like kill
switches) are more permanent, though.

In the server codebase, we delete the Waffle flag or switch using a database
migration, then we remove the old code (including the toggle) and we update the
test suite accordingly.

## Bonus: amo-info

I created a [Firefox extension called
"amo-info"](https://addons.mozilla.org/en-US/firefox/addon/amo-info/) to display
various information about the public-facing part of the AMO platform. Among
other things, this extension shows the configuration of our frontend toggles to
quickly see which features are enabled/disabled in our different environments:

![Screenshot of the amo-info Firefox extension](/images/posts/2020/09/amo-info.png)

That's it for today :-) Are you using feature toggles too? I'd be interested in
knowing how you manage them and what you do differently than than we do. Don't
hesitate to get in touch!
