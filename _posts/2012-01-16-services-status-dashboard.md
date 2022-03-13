---
layout: post
title: Services status dashboard
location: Clermont-Fd Area, France
updates:
  - date: 2022-03-12
    content: I proofread this article and removed dead links.
---

Today, I was looking for an Open Source alternative to
[Pingdom](http://www.pingdom.com/a1/) as I needed something free, customizable,
and lightweight. I love the [GitHub's Status Panel](http://status.github.com),
unfortunately they didn't open source it.

This kind of application is somewhat simple. You need a crawler, and few rules
to know whether an application is alive or not. Additionally, you may want to
store results in order to make graphs or calculate uptime average. Before
writing such a tool myself, I tried to find existing projects on GitHub.

Good news! I found a nice project: [Status
Dashboard](https://github.com/obazoud/statusdashboard) created by Olivier
Bazoud. This project is simple to configure, you can use provided plugins
(Twitter, IRC bot, History, ...) or add your owns, and you can monitor various
services (not only HTTP). If you don't want to use the beautiful interface, then
you'll find a REST API as well.

![A screenshot of the Services Status Dashboard application](/images/posts/2012/01/statusdashboard.webp)

### Installation

Run `npm install` to setup the project and its dependencies, then add your own
configuration in `settings.js`. Mine is:

```javascript
// ...
settings["william"] = {
  services: [
    {
      name: "williamdurand.fr",
      label: "William Durand (blog)",
      check: "http",
      host: "williamdurand.fr",
      port: "80",
      path: "/",
      headers: {
        Host: "williamdurand.fr",
      },
    },
  ],
  plugins: {
    history: {
      enable: true,
      host: "127.0.0.1",
      port: 6379,
      namespace: "statusdashboard",
      options: {},
      client: true,
    },
  },
};
```

Then, start the server:

    node server.js

Check the server is running by browsing _http://127.0.0.1:8080/_ or by querying
the API:

    > curl http://127.0.0.1:8080/api/services
    {"lastupdate":"Mon, 16 Jan 2012 13:29:11 GMT","services":[{"name":"williamdurand.fr","label":"William Durand (blog)","status":"up","statusCode":200,"message":""}],"summarize":{"lastupdate":"Mon, 16 Jan 2012 13:29:11 GMT","up":1,"critical":0,"down":0,"unknown":0}}

The project is available at:
[https://github.com/obazoud/statusdashboard](https://github.com/obazoud/statusdashboard).
