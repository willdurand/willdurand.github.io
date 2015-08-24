---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: true
title: "Please. Don't Patch Like An Idiot."
---

<style>
  .language-http .err {
    color: #bf616a!important;
    background: none!important;
  }
</style>

Modifying HTTP resources is not a new topic. Most of the existing HTTP or REST
APIs provide a way to modify resources. They often provide such a feature by
using the `PUT` method on the resource, asking clients to **send the entire
resource** with the updated values, but that requires a recent `GET` on its
resource, and a way to not miss updates between this `GET` call, and the `PUT`
one. Indeed, one may update values before you, and it can lead to bad side
effects. Moreover, sending a complete resource representation utilizes **more
bandwidth**, and sometimes it must be taken into account. Also, most of the time
you want to update one or two values in a resource, not everything, so the `PUT`
method is probably not the right solution for partial update, which is the term
used to describe such a use case.

Another solution is to expose the resource's properties you want to make
editable, and use the `PUT` method to send an updated value. In the example
below, the `email` property of user `123` is exposed:

```http
PUT /users/123/email

new.email@example.org
```

While it makes things clear, and it looks like a nice way to decide what to
expose and what not to expose, this solution introduces a lot of complexity
into your API (more actions in the controllers, routing definition,
documentation, etc.). However, it is REST compliant, and a not-so-bad solution,
but there is a better alternative: `PATCH`.

`PATCH` is an HTTP method (a.k.a. verb) which has been described in [RFC
5789](https://tools.ietf.org/html/rfc5789). The initial idea was to propose a
new way to modify existing HTTP resources. The biggest issue with this method
is that people misunderstand its usage. **No! `PATCH` is not about sending an
updated value, rather than the entire resource** as described in the first
paragraph of this article. Please, **stop** doing this right now! This is
**wrong**:

```http
PATCH /users/123

{ "email": "new.email@example.org" }
```

And, this is **wrong** too:

```http
PATCH /users/123?email=new.email@example.org
```

The `PATCH` method requests that **a set of changes**, described in the request
entity, must be applied to the resource identified by the request's URI. This
set contains **instructions** describing how a resource currently residing on
the origin server should be modified to produce a new version. You can think of
this as a **diff**:

```http
PATCH /users/123

[description of changes]
```

The entire set of changes must be applied **atomically**, and the API must never
provide a partially modified representation by the way. It is worth mentioning
that the request entity to `PATCH` is of a **different content-type** than the
resource that is being modified.  You have to use a media type that defines
semantics for PATCH, otherwise you lose the advantage of this method, and you
can use either `PUT` or `POST`. From the RFC:

> The difference between the PUT and PATCH requests is reflected in the way the
> server processes the enclosed entity to modify the resource identified by the
> Request-URI. In a PUT request, the enclosed entity is considered to be a
> modified version of the resource stored on the origin server, and the client is
> requesting that the stored version be replaced. With PATCH, however, **the
> enclosed entity contains a set of instructions describing how a resource
> currently residing on the origin server should be modified to produce a new
> version**. The PATCH method affects the resource identified by the Request-URI,
> and it also MAY have side effects on other resources; i.e., new resources may be
> created, or existing ones modified, by the application of a PATCH.

You can use whatever format you want as `[description of changes]`, as far as its
semantics is well-defined. That is why using `PATCH` to send updated values only
is not suitable.

[RFC 6902](http://tools.ietf.org/html/rfc6902) defines a **JSON document
structure** for expressing a **sequence of operations** to apply to a JSON
document, suitable for use with the `PATCH` method. Here is how it looks like:

```json
[
    { "op": "test", "path": "/a/b/c", "value": "foo" },
    { "op": "remove", "path": "/a/b/c" },
    { "op": "add", "path": "/a/b/c", "value": [ "foo", "bar" ] },
    { "op": "replace", "path": "/a/b/c", "value": 42 },
    { "op": "move", "from": "/a/b/c", "path": "/a/b/d" },
    { "op": "copy", "from": "/a/b/d", "path": "/a/b/e" }
]
```

It relies on **JSON Pointers**, described in [RFC
6901](http://tools.ietf.org/html/rfc6901), to identify specific values in a JSON
document, i.e. in a HTTP resource representation.

Modifying the email of the user `123` by applying the `PATCH` method to its JSON
representation looks like this:

```http
PATCH /users/123

[
    { "op": "replace", "path": "/email", "value": "new.email@example.org" }
]
```

So readable, and expressive! Wonderful &hearts; **This** is how the `PATCH`
method MUST be used.  If it succeeds, you get a `200` response.

For XML aficionados, [RFC 5261](http://tools.ietf.org/html/rfc5261) describes an
XML patch framework utilizing XML Path language (XPath) selectors to update an
existing XML document.

To sum up, the `PATCH` method is not a replacement for the `POST` or `PUT`
methods. It applies a delta (diff) rather than replacing the entire resource.
The request entity to `PATCH` is of a **different content-type** that the
resource that is being modified. Instead of being an entire resource
representation, it is a resource that describes changes to apply on a resource.

Now, please, either don't use the `PATCH` method, or use it the right way!

It is worth mentioning that `PATCH` is not really designed for truly REST APIs,
as Fielding's dissertation does not define any way to **partially** modify
resources. But, Roy Fielding himself said that
[PATCH was something \[he\] created for the initial HTTP/1.1 proposal because partial
PUT is never RESTful](https://twitter.com/fielding/status/275471320685367296).
Sure you are not transferring a **complete** representation, but REST does not
require representations to be complete anyway.

Useful Links
------------

* [An Extensible Markup Language (XML) Patch Operations Framework Utilizing XML
  Path Language (XPath) Selectors](http://tools.ietf.org/html/rfc5261)
* [PATCH Method for HTTP](https://tools.ietf.org/html/rfc5789)
* [JavaScript Object Notation (JSON) Pointer](http://tools.ietf.org/html/rfc6901)
* [JavaScript Object Notation (JSON) Patch](http://tools.ietf.org/html/rfc6902)
* [Why PATCH is Good for Your HTTP API](http://www.mnot.net/blog/2012/09/05/patch)
* [REST Partial Updates: Use POST, PUT or
  PATCH?](http://jasonsirota.com/rest-partial-updates-use-post-put-or-patch)
* [Embrace, Extend then
  Innovate](http://intertwingly.net/blog/2008/02/15/Embrace-Extend-then-Innovate)
* [Why isn't HTTP PUT allowed to do partial updates in a REST
  API?](http://stackoverflow.com/questions/19732423/why-isnt-http-put-allowed-to-do-partial-updates-in-a-rest-api)
* [The Right Way to Do REST
  Updates](http://blog.earaya.com/blog/2013/05/30/the-right-way-to-do-rest-updates/)
* [HTTP PUT, PATCH or POST - Partial updates or full
  replacement?](http://soabits.blogspot.fr/2013/01/http-put-patch-or-post-partial-updates.html)
