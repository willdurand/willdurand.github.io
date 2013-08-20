---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: false
tags: [ PHP, DDD ]
title: "DDD with Symfony2: Folder Structure And Code First"
---

_2013-08-11 - Move JMSSerializerBundle configuration files into the `ApiBundle`
bundle._

[Domain Driven Design](http://en.wikipedia.org/wiki/Domain-driven_design) also
known as **DDD** is an approach to develop software for complex needs by
connecting the implementation to an evolving model. [It is a way of thinking and
a set of priorities, aimed at accelerating software projects that have to deal
with complicated domains](http://dddcommunity.org/learning-ddd/what_is_ddd/).

It is possible to use this approach in a Symfony2 project, and that is what I am
going to introduce in a series of blog posts. You will learn how to build an
[application that manages users through a REST
API](/2012/08/02/rest-apis-with-symfony2-the-right-way/) using **D**omain
**D**riven **D**esign.


## Bootstrap

Start by creating a fresh project using the
[symfony-standard](https://github.com/symfony/symfony-standard) edition:

    composer create-project symfony/framework-standard-edition path/to/install

I use to remove unecessary files such as `src/*`, as well as useless bundles. My
`composer.json` file requires the following packages (for now):

``` json
"require": {
    "php": ">=5.3.3",
    "symfony/symfony": "2.3.*",
    "sensio/distribution-bundle": "2.3.*",
    "twig/extensions": "1.0.*",
    "symfony/monolog-bundle": "2.3.*",
    "incenteev/composer-parameter-handler": "~2.0",
    "sensio/framework-extra-bundle": "~2.3"
}
```

Don't forget to update the `AppKernel` class accordingly. You are now ready!


## Folder Structure

As Mathias Verraes stated in his blog post about [Code Folder
Structures](http://verraes.net/2011/10/code-folder-structure/), most of the
usual Symfony2 project folder structures are **not efficient**. That is why it
is important to spend some time designing a decent folder structure.

In your case, the domain expert said _users_ are **centrepieces**. The word
_User_ is part of the [Ubiquitous
Language](http://martinfowler.com/bliki/UbiquitousLanguage.html), the term [Eric
Evans](http://www.amazon.com/gp/product/0321125215) uses in **DDD** for the
practice of building up a common, rigorous language between developers and
users.

At first glance, it sounds like a good idea to create a `CoreDomainBundle` or
even a `UserBundle` bundle that will own users related things. _[Nein Nein Nein
Nein Nein Nein!](http://www.youtube.com/watch?v=xoMgnJDXd3k)_ I too often say
that **bundles should integrate libraries**, and I am not the [only
one](http://richardmiller.co.uk/2013/06/18/symfony2-bundle-structure-bundles-as-integration-layers-for-libraries/).

This also applies to your bundles, so users related stuff will better live in a
`CoreDomain` package:

    src
    └── Acme
        └── CoreDomain
            └── User

However, you still need a `CoreDomainBundle` bundle in order to integrate your
`CoreDomain` package into your Symfony2 project:

    src
    └── Acme
        ├── CoreDomain
        │   └── User
        └── CoreDomainBundle
            └── AcmeCoreDomainBundle.php

This package is part of the **Domain Layer**. This layer is the **heart** of
your application. **Business rules and logic live inside this layer**. Business
entity state and behavior are defined and used here. Next section is about
designing this **Domain Layer** using a **Code First** approach.


## Code First

The **Code First** approach provides an alternative to the well-known **Database
First** approach. As far as I know, it comes from the Microsoft world, but it
does not really matter.

Using a Database First approach, you design your database schema, and then
generate your classes. That is how [Propel](http://propelorm.org) works for
instance. It is [RAD](http://en.wikipedia.org/wiki/Rapid_application_development)
compliant, but it does not fit the **DDD** mindset.

Let's try the **Code First** approach then. Basically, start by writing your
classes, think in term of objects, not tables. You don't have to take care of
the database yet. The **domain expert** said a `User` has an _identifier_, a
_first name_, and a _last name_.

The `User` class is called an
[Entity](http://devlicio.us/blogs/casey/archive/2009/02/13/ddd-entities-and-value-objects.aspx)
in **DDD** as it has an **identity**. It is unique within the system.
**Identity** can be represented in many ways on an entity, it could be a numeric
identifier, a [GUID](http://en.wikipedia.org/wiki/Globally_unique_identifier),
or a natural key. Note that these [Entities](http://dddsample.sourceforge.net/characterization.html#Entities)
are not the same as the [Doctrine](http://www.doctrine-project.org/) ones. They
might be Doctrine classes, but they don't have to be.

``` php
<?php

namespace Acme\CoreDomain\User;

class User
{
    private $id;

    private $firstName;

    private $lastName;

    public function __construct(UserId $id, $firstName, $lastName)
    {
        $this->id        = $id;
        $this->firstName = $firstName;
        $this->lastName  = $lastName;
    }

    public function getId()
    {
        return $this->id;
    }

    public function getFirstName()
    {
        return $this->firstName;
    }

    public function getLastName()
    {
        return $this->lastName;
    }
}
```

Generally speaking, try to
[avoid](/2013/06/03/object-calisthenics/#9-no-getters/setters/properties)
[setters](http://whitewashing.de/2012/08/22/building_an_object_model__no_setters_allowed.html)
in order to make your code
[solid](/2013/07/30/from-stupid-to-solid-code/#open/closed-principle).
You could use a [Value
Object](http://dddsample.sourceforge.net/characterization.html#Value_Objects)
to [represent the name of the
user](/2013/06/03/object-calisthenics/#8-no-classes-with-more-than-two-instance-variables)
but it is not mandatory.


By the way, a [Value Object](http://martinfowler.com/eaaCatalog/valueObject.html)
is a simple object whose equality is **not based on identity**, instead two
Value Objects are equal if all their fields are equal. Value Objects can be a
Money or date range object. Their key property is that they follow value
semantics rather than reference semantics. [They don’t however have any value
other than by virtue of their
attributes](http://www.codeproject.com/Articles/339725/Domain-Driven-Design-Clear-Your-Concepts-Before-Yo).
Also, [Value Objects should be
immutable](http://c2.com/cgi/wiki?ValueObjectsShouldBeImmutable). If you want to
change a Value Object you should replace the object with a new one.

As you might noticed, the `User` identifier is represented by a `UserId`
instance, not a scalar type because you don't know which type to use. Will it be
a numeric identifier or a GUID? You don't know yet. Also, instead of passing IDs
everywhere, having a class for them makes this very explicit. This `UserId`
class is your very first **Value Object**:

``` php
<?php

namespace Acme\CoreDomain\User;

class UserId
{
    private $value;

    public function __construct($value)
    {
        $this->value = (string) $value;
    }

    public function getValue()
    {
        return $this->value;
    }
}
```

The domain expert said the application will manage **users**, so your
application will deal with a **collection** of users. In **DDD**, a collection
can be implemented by using the
[Repository](http://martinfowler.com/eaaCatalog/repository.html) design pattern.

A Repository mediates between the domain and data mapping using a
**collection-like interface** for accessing domain objects. It is **not** a Data
Access Layer though, as it deals with Entities and Value Objects. Note that there
are [various Repository implementation
patterns](http://lostechies.com/jimmybogard/2009/09/03/ddd-repository-implementation-patterns/)
but, in your case, here is how your `UserRepository` interface should look like:

``` php
<?php

namespace Acme\CoreDomain\User;

interface UserRepository
{
    public function find(UserId $userId);

    public function findAll();

    public function add(User $user);

    public function remove(User $user);
}
```

You should end up with the following folder structure:

    src
    └── Acme
        ├── CoreDomain
        │   └── User
        │       ├── User.php
        │       ├── UserId.php
        │       └── UserRepository.php
        └── CoreDomainBundle
            └── AcmeCoreDomainBundle.php

Now that you have a decent **Domain Layer** with Entities, Value Objects, and
Repositories, let's wire it to your Symfony2 application. Note that your
**Domain Layer** is **reusable**, and loosely coupled. That is really important!


## The Infrastructure Layer

In a **Code First** approach, you can **delay the decision** to choose a
persistence layer. The main advantage is to be able to write some other parts of
the application without having to wait.

You can create a `InMemoryUserRepository` class that implements the
`UserRepository` interface which contains hardcoded objects:

``` php
<?php

namespace Acme\CoreDomainBundle\Repository;

use Acme\CoreDomain\User\User;
use Acme\CoreDomain\User\UserId;
use Acme\CoreDomain\User\UserRepository;

class InMemoryUserRepository implements UserRepository
{
    private $users;

    public function __construct()
    {
        $this->users[] = new User(
            new UserId('8CE05088-ED1F-43E9-A415-3B3792655A9B'), 'John', 'Doe'
        );
        $this->users[] = new User(
            new UserId('62A0CEB4-0403-4AA6-A6CD-1EE808AD4D23'), 'Jean', 'Bon'
        );
    }

    public function find(UserId $userId)
    {
    }

    public function findAll()
    {
        return $this->users;
    }

    public function add(User $user)
    {
    }

    public function remove(User $user)
    {
    }
}
```

Here is what you should get by running `tree src/`:

    src
    └── Acme
        ├── CoreDomain
        │   └── User
        │       ├── User.php
        │       ├── UserId.php
        │       └── UserRepository.php
        └── CoreDomainBundle
            ├── Repository
            │   └── InMemoryUserRepository.php
            └── AcmeCoreDomainBundle.php

The `InMemoryUserRepository` class is part of what people call the
**Infrastructure Layer** in **DDD**, and is located into the `CoreDomainBundle`
bundle because it is specific to the application. The **Infrastructure Layer**
contains technical services, persistence, and more generally, concrete
implementations of the **Domain Layer**.

Register a new service named `user_repository` so that the **Application Layer**
is able to access the `UserRepository` repository. The
**Application Layer** can be seen as the **Controller Layer** in a
[Model-View-Controller](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
architecture. The **Application Layer** is in charge of **coordinating the
actions to be performed on the domain**, and delegates all domain actions to the
domain itself. This layer is kept thin. It **does not contain business rules**
or knowledge. It **does not have state reflecting the business situation**, but
it **can have state that reflects the progress of a task** for the user or the
program.

By the way, you will need to [write an `Extension` class in order to load bundle's service
configuration](http://symfony.com/doc/current/cookbook/bundles/extension.html#loading-external-configuration-resources)
but I won't cover that part.

The `user_repository` service acts as an **interface**. It is an
[alias](http://symfony.com/doc/current/components/dependency_injection/advanced.html#aliasing)
that points to a **concrete implementation** which is a **non-public** service:

``` xml
<!-- src/Acme/CoreDomainBundle/Resources/config/repositories.xml -->
<?xml version="1.0" ?>
<container xmlns="http://symfony.com/schema/dic/services"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://symfony.com/schema/dic/services http://symfony.com/schema/dic/services/services-1.0.xsd">

    <parameters>
        <parameter key="user_repository.in_memory.class">Acme\CoreDomainBundle\Repository\InMemoryUserRepository</parameter>
    </parameters>

    <services>
        <!-- Exposed Services -->
        <service id="user_repository" alias="user_repository.in_memory"></service>

        <!-- Concrete Implementations -->
        <service id="user_repository.in_memory" public="false" class="%user_repository.in_memory.class%"></service>
    </services>
</container>
```

Later when you will choose your persistence layer, you will just have to change
the alias to another concrete implementation like `user_repository.doctrine` for
instance, but you won't have to change your **Application Layer** code.


## The Application Layer

What you have to build is a REST API. The code will live in a bundle named
`ApiBundle`:

    src
    └── Acme
        ├── ApiBundle
        │   ├── Controller
        │   │   └── UserController.php
        │   ├── Resources
        │   │   └── config
        │   │       └── routing.yml
        │   └── AcmeApiBundle.php
        ├── CoreDomain
        │   └── User
        │       ├── User.php
        │       ├── UserId.php
        │       └── UserRepository.php
        └── CoreDomainBundle
            ├── DependencyInjection
            │   └── AcmeCoreDomainExtension.php
            ├── Repository
            │   └── InMemoryUserRepository.php
            └── AcmeCoreDomainBundle.php

You will need the following dependencies in your `composer.json` file:

``` json
"require": {
    ...

    "friendsofsymfony/rest-bundle": "0.13.*@dev",
    "jms/serializer-bundle": "0.12.*@dev"
}
```

Don't forget to register the bundles in the `AppKernel` class.

For now, you will implement only one action to retrieve all users into your
`UserController` class:

``` php
<?php

namespace Acme\ApiBundle\Controller;

use FOS\RestBundle\Controller\Annotations as Rest;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class UserController extends Controller
{
    /**
     * @Rest\View
     */
    public function allAction()
    {
        $users = $this->get('user_repository')->findAll();

        return array('users' => $users);
    }
}
```

There is no black magic here, things won't work out of the box. Let's take a
look at the configuration. First, you need to add a new route to your routing
definition:

``` yaml
# src/Acme/ApiBundle/Resources/config/routing.yml
acme_api.user_all:
    pattern:  /users.{_format}
    defaults: { _controller: AcmeApiBundle:User:all, _format: ~ }
    requirements:
        _method: GET
```

You also need to configure both
[FOSRestBundle](https://github.com/friendsofsymfony/FOSRestBundle) and
[SensioFrameworkExtraBundle](https://github.com/sensiolabs/SensioFrameworkExtraBundle):

``` yaml
# app/config/config.yml
fos_rest:
    view:
        view_response_listener: force
    format_listener:
        default_priorities: ['json', 'html', '*/*']
        fallback_format: json
        prefer_extension: true

sensio_framework_extra:
    view:    { annotations: false }
```

At this time, you should be able to access `http://yourproject.local/users`, but
it should throw an exception saying the Twig template named
`AcmeApiBundle:User:all.html.twig` does not exist.
However, if you browse `http://yourproject.local/users.json`, you should get JSON
content containing your users.

Thing is, it is not well serialized. That is because you didn't configure
[JMSSerializerBundle](https://github.com/schmittjoh/JMSSerializerBundle) yet.
First of all, you need to tell the
[Serializer](https://github.com/schmittjoh/serializer) where to find
configuration files:

``` yaml
# app/config/config.yml
jms_serializer:
    metadata:
        directories:
            CoreDomain:
                namespace_prefix: "Acme\\CoreDomain"
                path: "@AcmeApiBundle/Resources/config/serializer/"
```

The `ApiBundle` owns the serializer configuration, it is one of its
responsibilities. As you can see, I **use a YAML configuration file**, not
annotations, because I don't want to pollute the agnostic **Domain Layer**.

Here is the configuration file for the `User` entity:

``` yaml
# src/Acme/ApiBundle/Resources/config/serializer/User.User.yml
Acme\CoreDomain\User\User:
    exclusion_policy: ALL
    properties:
        id:
            expose: true
            inline: true
        firstName:
            expose: true
            serialized_name: first_name
        lastName:
            expose: true
            serialized_name: last_name
```

And here is the configuration file for the `UserId` value object:

``` yaml
# src/Acme/ApiBundle/Resources/config/serializer/User.UserId.yml
Acme\CoreDomain\User\UserId:
    exclusion_policy: ALL
    properties:
        value:
            expose: true
            serialized_name: id
```

That should give you the following JSON content:

``` json
{
    "users": [
        {
            "id":"8CE05088-ED1F-43E9-A415-3B3792655A9B",
            "first_name":"John",
            "last_name":"Doe"
        },
        {
            "id":"62A0CEB4-0403-4AA6-A6CD-1EE808AD4D23",
            "first_name":"Jean",
            "last_name":"Bon"
        }
    ]
}
```

Running `tree src/` on the command line should give you the following output:

    src
    └── Acme
        ├── ApiBundle
        │   ├── Controller
        │   │   └── UserController.php
        │   ├── Resources
        │   │   ├── config
        │   │   │   ├── routing.yml
        │   │   │   └── serializer
        │   │   │       ├── User.User.yml
        │   │   │       └── User.UserId.yml
        │   │   └── views
        │   │       └── User
        │   │           └── all.html.twig
        │   └── AcmeApiBundle.php
        ├── CoreDomain
        │   └── User
        │       ├── User.php
        │       ├── UserId.php
        │       └── UserRepository.php
        └── CoreDomainBundle
            ├── DependencyInjection
            │   └── AcmeCoreDomainExtension.php
            ├── Repository
            │   └── InMemoryUserRepository.php
            ├── Resources
            │   └── config
            │       └── repositories.xml
            └── AcmeCoreDomainBundle.php


## Conclusion

Adopting the right **folder structure** in your code is important. You should
always decouple your code as much as possible. By remembering that a bundle
**integrates** a third-party library or just a set of agnostic classes, you end
up with a clean separation between Symfony2 related things, and your business
logic.

Bundles that integrate your **Domain Layer** packages are part of the
**Infrastructure Layer**. Your controllers are part of the  **Application
Layer**. The missing layer is the **Presentation Layer** (UI) which talk to
the **Application Layer**. This layer is responsible for displaying information
to the user, and accept new data, but I will cover it in another article.

![](/images/posts/ddd.png)

<small class="source">Source: <a href="http://guptavikas.wordpress.com/2009/12/01/domain-driven-design-an-introduction/">http://guptavikas.wordpress.com/2009/12/01/domain-driven-design-an-introduction/</a></small>

By using the **Code First** approach, you have been able to write a first
action that just works. You won't have to change it. However, you will be able
to rely on a database or whatever you want later on. It will be up to you.

In the next blog post, I will <strike>introduce the **Presentation Layer**, new Value
Objects such as the `Name` one, and more on **DDD**!</strike> [cover a few points that
have been misunderstood](/2013/08/20/ddd-with-symfony2-making-things-clear/).
