---
layout: post
title: Services Status Dashboard
location: Clermont-Fd Area, France
---

Today, I was looking for an Open Source alternative to [Pingdom](http://www.pingdom.com/a1/) as I needed something
free, customizable, and lightweight. I love the [GitHub's Status Panel](http://status.github.com), unfortunately
they didn't open source it.

Basically, this kind of application is simple. You just need a crawler, and few rules to know whether an application is alive
or not. Additionally, you may want to store results in order to make graphs or to calculate uptime average, and so on.
Before to write this kind of application myself, I tried to search existing projects on GitHub.

Good news! I found a really nice project: [Status Dashboard](https://github.com/obazoud/statusdashboard) created by
Olivier Bazoud. This project is easy to configure, you can use provided plugins (Twitter, IRC bot, History, ...) or add your owns,
and you can monitor various services (not only HTTP). If you don't want to use the beautiful interface, then you'll find
a REST API.

![](/images/posts/statusdashboard.png)

### Installation

Run `npm install` to setup the project and its dependencies, then add your own configuration in `settings.js`. Mine is:

{% highlight js %}
// ...
settings['william'] = {
  services: [{
    name: 'williamdurand.fr',
    label: 'William DURAND (blog)',
    check: 'http',
    host: 'williamdurand.fr',
    port: '80',
    path: '/',
    headers: {
    'Host': 'williamdurand.fr'
    }
  }],
  plugins: {
    history: {
    enable: true,
    host: "127.0.0.1",
    port: 6379,
    namespace: "statusdashboard",
    options: {
    },
    client: true
    }
  }
};
{% endhighlight %}

Then, start the server:

    node server.js

Check the server is running by browsing _http://127.0.0.1:8080/_ or by querying the API:

    > curl http://127.0.0.1:8080/api/services
    {"lastupdate":"Mon, 16 Jan 2012 13:29:11 GMT","services":[{"name":"williamdurand.fr","label":"William DURAND (blog)","status":"up","statusCode":200,"message":""}],"summarize":{"lastupdate":"Mon, 16 Jan 2012 13:29:11 GMT","up":1,"critical":0,"down":0,"unknown":0}}

The project is available at: [https://github.com/obazoud/statusdashboard](https://github.com/obazoud/statusdashboard).
