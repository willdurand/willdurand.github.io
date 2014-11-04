---
layout: post
title: "REST APIs with Symfony2: The Right Way"
location: Zürich, Switzerland
audio: false
tags: [ PHP ]
---

_2O14-02-14 - [PATCH should not be used the way it has been described
here](/2014/02/14/please-do-not-patch-like-an-idiot/)._

_2013-04-12 - Add an example on how to create new resources with PUT._

_2013-04-11 - PUT/PATCH methods should not return a `Location`
header in the context of this blog post, as PUT is used to **update** an
existing resource **only**, so it naturally returns a `204` status code._

Designing a **REST** API is not easy. No, really! If you want to design an API the
right way, you have to think a lot about everything, and either to be pragmatic
or to be an API terrorist. It's not just about **GET**, **POST**, **PUT**, and
**DELETE**. In real life, you have relations between **resources**, the need to
move a resource somewhere else (think about a tree), or you may want to set a
specific value to a resource.

This article will sum up everything I learnt by building different APIs, and
how I used [Symfony2](http://github.com/symfony/symfony), the
[FOSRestBundle](http://github.com/FriendsOfSymfony/FOSRestBundle), the
[NelmioApiDocBundle](http://github.com/nelmio/NelmioApiDocBundle), and
[Propel](http://github.com/propelorm/Propel).
Let's say we will build a User API.


### Do you speak...? ###

An API is used by clients. They need to know how to talk to your API, and a
decent documentation is a good start, and will be described at the end of this
article.

Actually, you also need to know how to talk to them too, and in the HTTP
protocol, there is something named the **Accept header**. Basically, your
clients will send a header with the format they want to get.

Thanks to the **FOSRestBundle**, everything is done for you. No need to handle
this part yourself, but you have to configure which formats you want to support.
Most of the time, you will use **JSON**, and if you take care of semantic
problematics, you will send **XML**. This part will be described later too.


### GET what? ###

The **GET** HTTP verb is idempotent. That means whatever you can do, when you
get a resource, you get the same response, and nothing should be altered.
You will use **GET** to return resources: either a collection, or a single
resource. In Symfony2, the routing definition would be:

{% highlight yaml %}
# src/Acme/DemoBundle/Resources/config/routing.yml

acme_demo_user_all:
    pattern:  /users
    defaults: { _controller: AcmeDemoBundle:User:all, _format: ~ }
    requirements:
        _method: GET

acme_demo_user_get:
    pattern:  /users/{id}
    defaults: { _controller: AcmeDemoBundle:User:get, _format: ~ }
    requirements:
        _method: GET
        id: "\d+"
{% endhighlight %}

The `UserController` class would contain the following code:

{% highlight php %}
<?php

namespace Acme\DemoBundle\Controller;

use Acme\DemoBundle\Model\User;
use Acme\DemoBundle\Model\UserQuery;
use FOS\RestBundle\Controller\Annotations as Rest;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class UserController
{
    /**
     * @Rest\View
     */
    public function allAction()
    {
        $users = UserQuery::create()->find();

        return array('users' => $users);
    }

    /**
     * @Rest\View
     */
    public function getAction($id)
    {
        $user = UserQuery::create()->findPk($id);

        if (!$user instanceof User) {
            throw new NotFoundHttpException('User not found');
        }

        return array('user' => $user);
    }
}
{% endhighlight %}

Instead of using a [ParamConverter](http://symfony.com/doc/master/bundles/SensioFrameworkExtraBundle/annotations/converters.html),
I always use to fetch the object myself in `get*()` methods. You will know later
why, just trust me for the moment, it's better.

**Status code** matter for your clients, so if the user doesn't exist, use a
`NotFoundHttpException` exception which returns a response with a `404` status
code.

By using the `View` annotation, you will render the user object using the right
format according to the user **Accept** header. Using an alias (`Rest`) for
this annotation is a trick to avoid confusion with the `View` object we will
discover later. Basically, the annotation relies on this class. It's just a
matter of taste whether you like annotations or not.

Last thing, the `allAction()` method has the same behavior, you fetch all your
users, and then you return them.

A user has four properties: an _id_, an _email_, a _username_ and a _password_.
You probably don't want to expose the password for some good reasons. The easiest
way to achieve that is to configure the serializer. I use to configure it in
YAML:

{% highlight yaml %}
# In Propel, the most part of the code is located in base classes
# src/Acme/DemoBundle/Resources/config/serializer/Model.om.BaseUser.yml
Acme\DemoBundle\Model\om\BaseUser:
    exclusion_policy: ALL
    properties:
        id:
            expose: true
        username:
            expose: true
        email:
            expose: true
{% endhighlight %}

I exclude all properties by default, it allows me more control on what I really
want to expose. It doesn't matter with four attributes, but it's always better
to adopt this strategy, it's like configuring a firewall after all.

Basically, you will get the following JSON response:

{% highlight javascript %}
{
  "user": {
    "id": 999,
    "username": "xxxx",
    "email": "xxxx@example.org"
  }
}
{% endhighlight %}

Easy right? But, you will probably need to create, update, or delete your users,
and that's what we will discover in the next sections.


### POST 'it ###

Creating a resource implies the use of the **POST** HTTP verb. But how do you get
data? How do you validate data? And how do you create your new resource? These
three questions have more than one answer or strategy.

You could use the deserialization mechanism to create an object from the input
serialized data. There is an interesting work in progress by
[Benjamin](http://twitter.com/beberlei) about [Form
deserialization](https://github.com/simplethings/SimpleThingsFormSerializerBundle).
It's a bit different than just using the
[Serializer component](https://github.com/symfony/Serializer) but it seems easier.

I use to use the awesome [Symfony Forms](https://github.com/symfony/Form) to do
everything at once. So let's write a Form type to create our users. Using the
PropelBundle, you could use the `propel:form:generate` command:

    php app/console propel:form:generate @AcmeDemoBundle User

It will create the following form type:

{% highlight php %}
<?php

namespace Acme\DemoBundle\Form\Type;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;

class UserType extends AbstractType
{
    /**
     * {@inheritdoc}
     */
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('username');
        $builder->add('email', 'email');
        $builder->add('password', 'password');
    }

    /**
     * {@inheritdoc}
     */
    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
            'data_class'        => 'Acme\DemoBundle\Model\User',
            'csrf_protection'   => false,
        ));
    }

    /**
     * {@inheritdoc}
     */
    public function getName()
    {
        return 'user';
    }
}
{% endhighlight %}

The only things I tweaked are the `email` and `password` types, and I disabled
the CSRF protection. In a REST API, you probably use an security layer like
OAuth for example. Having a CSRF protection in a REST context doesn't make sense.

Now, you want to add validation rules, and thanks to the [Validator
component](http://symfony.com/doc/master/book/validation.html), it's really
powerful. I definitely love this component because it becomes simple to validate
all data you want in a safe way.

Back to our use case, I use to define my validation rules in YAML, but feel free
to use your preferred way. Here is an example:

{% highlight yaml %}
# src/Acme/DemoBundle/Resources/config/validation.yml
Acme\DemoBundle\Model\User:
    getters:
        username:
            - NotBlank:
        email:
            - NotBlank:
            - Email:
        password:
            - NotBlank:
{% endhighlight %}

Let's write the controller method now:

{% highlight php %}
<?php

// ...

    public function newAction()
    {
        return $this->processForm(new User());
    }
{% endhighlight %}

New tip, always use a method to process your form. You will thank yourself.
The `processForm()` method looks like:

{% highlight php %}
<?php

// ...

    private function processForm(User $user)
    {
        $statusCode = $user->isNew() ? 201 : 204;

        $form = $this->createForm(new UserType(), $user);
        $form->handleRequest($this->getRequest());

        if ($form->isValid()) {
            $user->save();

            $response = new Response();
            $response->setStatusCode($statusCode);

            // set the `Location` header only when creating new resources
            if (201 === $statusCode) {
                $response->headers->set('Location',
                    $this->generateUrl(
                        'acme_demo_user_get', array('id' => $user->getId()),
                        true // absolute
                    )
                );
            }

            return $response;
        }

        return View::create($form, 400);
    }
{% endhighlight %}

Basically, you create a form, you bind input data, if everything is valid, you
save your user, and you return a response. If something went wrong, you return a
**`400`** status code with the form.
The `$form` instance will be serialized to highlight invalid input data. For
example, you could get the following error response:

{% highlight javascript %}
{
  "code": 400,
  "message": "Validation Failed";
  "errors": {
    "children": {
      "username": {
        "errors": [
          "This value should not be blank."
        ]
      }
    }
  }
}
{% endhighlight %}


Note that the `View` class here is not the same as the annotation one, that's why
I used an alias earlier. Read more about this class in [The View
Layer](https://github.com/FriendsOfSymfony/FOSRestBundle/blob/master/Resources/doc/2-the-view-layer.md)
chapter in the FOSRestBundle documentation.

Also, passing the form name is important here. Basically, your clients will send the following content:

{% highlight javascript %}
{
  "user": {
    "username": "foo",
    "email": "foo@example.org",
    "password": "hahaha"
  }
}
{% endhighlight %}

You can try this API method with `curl`:

    curl -v -H "Accept: application/json" -H "Content-type: application/json" -X
    POST -d '{"user":{"username":"foo", "email": "foo@example.org", "password":
    "hahaha"}}' http://example.com/users

Make sure to set the `body_listener` parameter to `true` in the FOSRestBundle
configuration. It allows you to receive data in JSON, XML, etc. Then again,
everything works out of the box.

As I said previously, when everything is ok, you persist the user
(`$user->save()` in Propel), and then you return a response.

You will return a **`201`** status code which means  _resource created_.
Note that I don't use the `View` annotation here.

But if you read the code, you may think that I did weird stuff. Actually, once a
resource is created, you have to return **only one information**: how to access
this resource, in other words, its **URI**.
The HTTP specification says you should use the **Location** header, and that's
what I do here. But, most of the time you don't want to perform a new request
to get information like the `id` of the user (you already have other information
anyway). Here is the beginning of my main concern: _pragmatic vs terrorist?_

Guess what? I use to be terrorist here, and I follow the specification by
returning just the **Location** header:

    Location: http://example.com/users/999


When I have a JavaScript framework like Backbone.js as client, and because I
don't want to rewrite it entirely because it doesn't support right APIs, I
return the `id` in addition. Being pragmatic is not a bad idea anyway.

Don't forget to add the routing definition for this action. Creating a resource
is a `POST` request to the collection, so let's add a new route:

{% highlight yaml %}
acme_demo_user_new:
    pattern:  /users
    defaults: { _controller: AcmeDemoBundle:User:new, _format: ~ }
    requirements:
        _method: POST
{% endhighlight %}

Once you know how to create a new resource, it's quite easy to update it.


### PUT vs PATCH, fight! ###

Updating a resource in REST means replacing it actually, especially if you use
the **PUT** HTTP verb. There is also the **PATCH** method which takes a diff as
input and applies a _patch_ to your resource, in other words, it's a **partial
update**.

Thanks to our previous work, updating a resource will be quickly implemented.
You have to write a new method in your controller, and to add a new route.
Here, I rely on a ParamConverter to fetch the User object. If it doesn't exist,
the converter will throw an exception and this exception will be converted in a
response with a **`404`** status code.

{% highlight php %}
<?php

// ...

    public function editAction(User $user)
    {
        return $this->processForm($user);
    }
{% endhighlight %}

Editing a resource means you know it, so you will perform a `PUT` request on
this resource:

{% highlight yaml %}
acme_demo_user_edit:
    pattern:  /users/{id}
    defaults: { _controller: AcmeDemoBundle:User:edit, _format: ~ }
    requirements:
        _method: PUT
{% endhighlight %}

Both **PUT** and **PATCH** methods have to return a **204** status code standing
for `No Content`, and meaning everything is ok, go ahead. In the context of this
blog post, **PUT** is exclusively used to **update existing resources**, not to
create new ones. That is why you have to return a `204` status code.

If you want to create new resources at a given URI, then you will have to update
the code above by removing the use of a ParamConverter, and create a new user in
case it does not exist:

{% highlight php %}
<?php

// ...

    public function editAction($id)
    {
        if (null === $user = UserQuery::create()->findPk($id)) {
            $user = new User();
            $user->setId($id);
        }

        return $this->processForm($user);
    }
{% endhighlight %}

In this case, your method can return either `204` if the resource exists or
`201` with a `Location` header if a new resource has been created.

That's it! What about deleting resources now?


### DELETE ###

Deleting a resource is super easy. Add a new route:

{% highlight yaml %}
acme_demo_user_delete:
    pattern:  /users/{id}
    defaults: { _controller: AcmeDemoBundle:User:remove, _format: ~ }
    requirements:
        _method: DELETE
{% endhighlight %}

And, write a short method:

{% highlight php %}
<?php

// ...

    /**
     * @Rest\View(statusCode=204)
     */
    public function removeAction(User $user)
    {
        $user->delete();
    }
{% endhighlight %}

In a few lines of code, you have a fully working API that exposes **CRUD**
operations in a safe way. But now, what about adding relationship between users,
like friendship?

_How to retrieve the friends for a given user in REST?_ We just have to consider
friends as a collection of users owned by the user. Let's implement that.


### The Friendship Algorithm ###

First, we have to create a new route. As we consider the friends as a collection
owned by a user, we will fetch this collection directly on a resource:

{% highlight yaml %}
acme_demo_user_get_friends:
    pattern:  /users/{id}/friends
    defaults: { _controller: AcmeDemoBundle:User:getFriends, _format: ~ }
    requirements:
        _method: GET
{% endhighlight %}

The action in the controller looks like:

{% highlight php %}
<?php

// ...

    public function getFriendsAction(User $user)
    {
        return array('friends' => $user->getFriends());
    }
{% endhighlight %}

That's it. Now, think about how to represent the process of becoming friend with
another user. _How would you manage that in a REST approach?_ You can't use `POST`
to the collection of friends as you won't create anything Both users already
exist. You can't use `PUT` as you don't really want to replace the whole
collection, and it seems a bit harsh.

Well, the HTTP procotol describes a `LINK` HTTP verb that solves this problem.
It says:

> The LINK method establishes one or more Link relationships between
> the existing resource identified by the Request-URI and other
> existing resources.

That's exactly what we need. We want to link two resources, we should never
forget resources while we build APIs. So, how to do that in Symfony2?

My approach is to rely on a request listener here. The client will perform a
`LINK` request on a resource, and will send at least one **Link** header:

    LINK /users/1
    Link: <http://example.com/users/2>; rel="friend"
    Link: <http://example.com/users/3>; rel="friend"

Using a request listener is a nice option because it allows you to have clean
inputs in your action. The aim of this action is to link objects after all, we
don't want to play with URIs in the controller. The transformation has to be
done before.

The request listener gets those **Link** headers, and uses the `RouterMatcher`
part of Symfony2 to retrieve the controller and the method names. It also
gets the parameters.

In other words, it has all information to create a controller, and to call the
right method on it with the right parameters. In our example, for each **Link**
header, it calls the `getUser()` action on the `UserController` controller.
That's why I didn't use ParamConverters, it allows me to pass the _id_ value,
and to get my resource. I make two assumptions:

* if the user doesn't exist, I will get an exception;
* I will get an array as returned value because I use the `View` annotation.

Once I get my resource objects, I put them in the request's attributes, and that's
all for the listener. Here is the code:

{% highlight php %}
<?php

namespace Acme\DemoBundle\EventListener;

use Symfony\Component\HttpKernel\Event\GetResponseEvent;
use Symfony\Component\HttpKernel\Controller\ControllerResolverInterface;
use Symfony\Component\Routing\Matcher\UrlMatcherInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\HttpKernelInterface;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\HttpKernel\Event\FilterControllerEvent;

class LinkRequestListener
{
    /**
     * @var ControllerResolverInterface
     */
    private $resolver;
    private $urlMatcher;

    /**
     * @param ControllerResolverInterface $controllerResolver The 'controller_resolver' service
     * @param UrlMatcherInterface         $urlMatcher         The 'router' service
     */
    public function __construct(ControllerResolverInterface $controllerResolver, UrlMatcherInterface $urlMatcher)
    {
        $this->resolver = $controllerResolver;
        $this->urlMatcher = $urlMatcher;
    }

    public function onKernelRequest(GetResponseEvent $event)
    {
        if (!$event->getRequest()->headers->has('link')) {
            return;
        }

        $links  = array();
        $header = $event->getRequest()->headers->get('link');

        /*
         * Due to limitations, multiple same-name headers are sent as comma
         * separated values.
         *
         * This breaks those headers into Link headers following the format
         * http://tools.ietf.org/html/rfc2068#section-19.6.2.4
         */
        while (preg_match('/^((?:[^"]|"[^"]*")*?),/', $header, $matches)) {
            $header  = trim(substr($header, strlen($matches[0])));
            $links[] = $matches[1];
        }

        if ($header) {
            $links[] = $header;
        }

        $requestMethod = $this->urlMatcher->getContext()->getMethod();
        // Force the GET method to avoid the use of the
        // previous method (LINK/UNLINK)
        $this->urlMatcher->getContext()->setMethod('GET');

        // The controller resolver needs a request to resolve the controller.
        $stubRequest = new Request();

        foreach ($links as $idx => $link) {
            $linkParams = explode(';', trim($link));
            $resource   = array_shift($linkParams);
            $resource   = preg_replace('/<|>/', '', $resource);

            try {
                $route = $this->urlMatcher->match($resource);
            } catch (\Exception $e) {
                // If we don't have a matching route we return
                // the original Link header
                continue;
            }

            $stubRequest->attributes->replace($route);

            if (false === $controller = $this->resolver->getController($stubRequest)) {
                continue;
            }

            // Make sure @ParamConverter and friends are handled
            $subEvent = new FilterControllerEvent($event->getKernel(), $controller, $stubRequest, HttpKernelInterface::MASTER_REQUEST);
            $event->getDispatcher()->dispatch(KernelEvents::CONTROLLER, $subEvent);
            $controller = $subEvent->getController();

            $arguments = $this->resolver->getArguments($stubRequest, $controller);

            try {
                $result = call_user_func_array($controller, $arguments);

                // By convention the controller action must return an array
                if (!is_array($result)) {
                    continue;
                }

                // The key of first item is discarded
                $links[$idx] = current($result);
            } catch (\Exception $e) {
                continue;
            }
        }

        $event->getRequest()->attributes->set('links', $links);
        $this->urlMatcher->getContext()->setMethod($requestMethod);
    }
}
{% endhighlight %}

Now, you can create a new route:

{% highlight yaml %}
acme_demo_user_link:
    pattern:  /users/{id}
    defaults: { _controller: AcmeDemoBundle:User:link, _format: ~ }
    requirements:
        _method: LINK
{% endhighlight %}

And the code of the action looks like:

{% highlight php %}
<?php

// ...

    /**
     * @Rest\View(statusCode=204)
     */
    public function linkAction(User $user, Request $request)
    {
        if (!$request->attributes->has('links')) {
            throw new HttpException(400);
        }

        foreach ($request->attributes->get('links') as $u) {
            if (!$u instanceof User) {
                throw new NotFoundHttpException('Invalid resource');
            }

            if ($user->hasFriend($u)) {
                throw new HttpException(409, 'Users are already friends');
            }

            $user->addFriend($u);
        }

        $user->save();
    }
{% endhighlight %}

If users are already friends, you will get a response with a **`409`** status
code which means _Conflict_. If there is no link header, it's a bad request
(`400`).

And it would be the same thing to remove friends. There is a `UNLINK` HTTP verb
too.

Last thing I didn't explain is the `PATCH` verb, I mean what would be a use case
for such a verb? The answer is partial update or every other methods that are
either not safe, unsure or not idempotent. If you have a custom API method, and
you don't know which verb to use, `PATCH` is probably the answer.

Assuming you allow your users to change their email thanks to a third party
client, then again it's for some good business reasons. This client uses a two
steps process. The user asks for changing his email, he gets an email with a
link and this link allows him to change his email. Let's skip the first part
and focus on the second one. The user sends a new password to the client, and
the client has to call your API.
Either this client will fetch the resource, and replace it or you are smart and
you provide a `PATCH` method.


### Let's PATCH the world ###

This section has been removed as it described a wrong way to use the `PATCH`
method. You can read this: [Please. Don't Patch Like An
Idiot.](/2014/02/14/please-do-not-patch-like-an-idiot/). It covers how to update
user's email, using the `PATCH` method the right way, but not in PHP
unfortunately.

So now, what's the plan? We use `GET`, `POST`, `PUT`, `DELETE`, `LINK`, and
`UNLINK` verbs. We are able to create, read, update, delete a user. We can get
all users, and add relationships between them.

Actually, regarding the [Richardson Maturity
Model](http://www.crummy.com/writing/speaking/2008-QCon/act3.html),
we just covered the level 2. Let's take a look at **HATEOAS** and unlock the
level 3!

![](http://williamdurand.fr/images/posts/richardson_maturity_model.png)


### Hate who? ###

HATEOAS is not about hating people, but you could hate this movement if you are
a true pragmatic programmer. It basically means **H**ypermedia **A**s **T**he
**E**ngine **O**f **A**pplication **S**tate. To me, it looks like a **semantic
dimension** you bring into your APIs.

Earlier in this article I talked about the format used to exchange information
between a client and your API. JSON is not the best choice when you want to
follow HATEOAS principles even if some
[people tried to provide solutions](https://github.com/kevinswiber/siren).

Let's convert our _User_ representation in XML:

{% highlight xml %}
<user>
    <id>999</id>
    <username>xxxx</username>
    <email>xxxx@example.org</email>
</user>
{% endhighlight %}

This is the output you could get by requesting the XML format as a client. There
is nothing HATEOAS here. The first step is the addition of **links**:

{% highlight xml %}
<user>
    <id>999</id>
    <username>xxxx</username>
    <email>xxxx@example.org</email>

    <link href="http://example.com/users/999" rel="self" />
</user>
{% endhighlight %}

This was easy, we just added the link that references the user you fetched. But
if you get a paginate collection of users, you could get:

{% highlight xml %}
<users>
    <user>
        <id>999</id>
        <username>xxxx</username>
        <email>xxxx@example.org</email>

        <link href="http://example.com/users/999" rel="self" />
        <link href="http://example.com/users/999/friends" rel="friends" />
    </user>
    <user>
        <id>123</id>
        <username>foobar</username>
        <email>foobar@example.org</email>

        <link href="http://example.com/users/123" rel="self" />
        <link href="http://example.com/users/123/friends" rel="friends" />
    </user>

    <link href="http://example.com/users?page=1" rel="prev" />
    <link href="http://example.com/users?page=2" rel="self" />
    <link href="http://example.com/users?page=3" rel="next" />
</users>
{% endhighlight %}

Now the client knows how to browse the collection, how to use the pager, and how
to fetch a user and/or its friends.

The second part is about adding **media types** to answer the question:
**What?**. What is this resource? What does it contain or what do I need to
create such a resource?

This part introduces your own **content type**:

    Content-Type: application/vnd.yourname.something+xml

Our users will now have the following content type:
`application/vnd.acme.user+xml`.

{% highlight xml %}
<user>
    <id>999</id>
    <username>xxxx</username>
    <email>xxxx@example.org</email>

    <link href="http://example.com/users/999" rel="self" />

    <link rel="friends"
          type="application/vnd.acme.user+xml"
          href="http://example.com/users/999/friends" />
</user>
{% endhighlight %}

Last, but not the least, you can add versioning to your API in three different
ways. First, you can add the version number in your URIs, this is the easy way:

    /api/v1/users

You can use your new content type:

    application/vnd.acme.user-v1+xml

Or you can also use a qualifier in your **Accept** header, that way you don't
touch your content type:

    application/vnd.acme.user+xml;v=1

It's really up to you. The first solution is easy but less RESTful than the two
other solutions. But those solutions require more smart clients.


### Testing ###

To be honest, if you decide to expose your API to your customers, this section
is the most important. You can decide to follow the REST approach or not, but
your API has to work perfectly, and that means well tested.

I use to test APIs I build with functional tests, that means I consider the
system as a black box. Symfony2 embeds a nice
[Client](http://symfony.com/doc/master/book/testing.html#working-with-the-test-client)
which allows you to call your API methods directly in your test classes:

{% highlight php %}
<?php

$client   = static::createClient();
$crawler  = $client->request('GET', '/users');

$response = $client->getResponse();

$this->assertJsonResponse($response, 200);
{% endhighlight %}

I use to use my own `WebTestCase` class with a `assertJsonResponse()` method:

{% highlight php %}
<?php

// ...

    protected function assertJsonResponse($response, $statusCode = 200)
    {
        $this->assertEquals(
            $statusCode, $response->getStatusCode(),
            $response->getContent()
        );
        $this->assertTrue(
            $response->headers->contains('Content-Type', 'application/json'),
            $response->headers
        );
    }
{% endhighlight %}

This is the first check I do after a call to the API. If it's ok, then I can
make more assertions related to the content I fetched.

When you write tests for your APIs, test everything you can think about. Don't
forget to test bad requests, and to have at least one test method for each
status code you can return. It's important because, even if there is a problem,
you have to return the right status code, and the right message to the clients.
A `500` status code doesn't have the same meaning than a `400`.


### Documentation ###

Having a well documented API is really important, because it's the only thing
your clients will have access to. You don't provide the entire code to them,
there is just an endpoint and documentation.

In a HATEOAS approach, your API is auto documented, so you don't need to write
the documentation yourself, because your clients will discover features
themselves.

But then again, having a HATEOAS API is quite complex, and it's not so
widespread nowadays. If your API follows the level 2 of the Richardson's model,
it's already good, but you will have to write the documentation yourself!

NelmioApiDocBundle to the rescue! I wrote this bundle at
[Nelmio](http://nelm.io) in order to automatically generate documentation for
our APIs. Based on code introspection, the bundle extracts a lot of information,
and displays a nice page with all information found:

![](https://github.com/nelmio/NelmioApiDocBundle/raw/master/Resources/doc/webview.png)

![](https://github.com/nelmio/NelmioApiDocBundle/raw/master/Resources/doc/webview2.png)

You now have all keys to build wonderful APIs!


### Useful Links ###

* [RFC 2616 - Section 10 - Status Code
  Definitions](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html);
* [RFC 2068 - Section 19.6 - Additional
  Features](http://tools.ietf.org/html/rfc2068#page-156);
* [RFC 5988 - Web Linking](http://tools.ietf.org/html/rfc5988).

I will probably update this post with more information, links, etc. So stay tuned!


<p class="ad">
Want to <strong>learn more</strong> about REST? Interested in reading more code? I
co-authored the <strong><a href="http://knpuniversity.com/screencast/rest">RESTful
APIs in the Real World screencast</a></strong>, and it is definitely worth buying it!
Yes, I know it is not free, but for me, it is a way to "sponsor" my Open Source work.
</p>
