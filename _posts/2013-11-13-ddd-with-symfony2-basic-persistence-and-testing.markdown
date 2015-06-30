---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: false
tags: [ PHP, DDD ]
title: "DDD with Symfony2: Basic Persistence &amp; Testing"
---

After having described [a decent folder
structure](/2013/08/07/ddd-with-symfony2-folder-structure-and-code-first/) and
[made things clear](/2013/08/20/ddd-with-symfony2-making-things-clear/) about
DDD and this series, I will continue to bootstrap the sample application,
focusing on a **basic persistence** layer and **testing**. It is not tied to
DDD but it is worth writing about these two points.

A **basic persistence** layer is a layer that is **simple**. In other words, it
does the job, period. It has poor performances, but it does not matter. What
matters is that you can develop your application without having to decide
whether you will use MySQL rather than a NoSQL database or an API for instance.


## The `YamlUserRepository` Repository

Until now, the application used the `InMemoryUserRepository` described in the
[first blog
post](/2013/08/07/ddd-with-symfony2-folder-structure-and-code-first/) of this
series. In order to introduce new concepts later in this series, you need a real
persistence layer that is able to **load** and **store** data. That is why you
need a `YamlUserRepository`.

For the record, [YAML](http://yaml.org/) is a data
serialization format that is both simple and **human readable**. You don't need
to focus on performance right now, so storing data in a file is ok.

Here is the implementation of the `YamlUserRepository`. That might not be the
perfect/best implementation but it actually works:

``` php
<?php

namespace Acme\CoreDomainBundle\Repository;

use Acme\CoreDomain\User\User;
use Acme\CoreDomain\User\UserId;
use Acme\CoreDomain\User\UserRepository;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Yaml\Yaml;

class YamlUserRepository implements UserRepository
{
    private $filename;

    public function __construct($filename)
    {
        $this->filename = $filename;

        (new Filesystem())->touch($this->filename);
    }

    /**
     * {@inheritDoc}
     */
    public function find(UserId $userId)
    {
        foreach ($this->findAll() as $user) {
            if ($user->getId()->isEqualTo($userId)) {
                return $user;
            }
        }

        return null;
    }

    /**
     * {@inheritDoc}
     */
    public function findAll()
    {
        $users = array();
        foreach ($this->getRows() as $row) {
            $users[] = new User(
                new UserId($row['id']),
                $row['first_name'],
                $row['last_name']
            );
        }

        return $users;
    }

    /**
     * {@inheritDoc}
     */
    public function add(User $user)
    {
        $rows = array();
        foreach ($this->getRows() as $row) {
            if ($user->getId()->isEqualTo(new UserId($row['id']))) {
                continue;
            }

            $rows[] = $row;
        }

        $rows[] = array(
            'id'         => $user->getId()->getValue(),
            'first_name' => $user->getFirstName(),
            'last_name'  => $user->getLastName(),
        );

        file_put_contents($this->filename, Yaml::dump($rows));
    }

    /**
     * {@inheritDoc}
     */
    public function remove(User $user)
    {
        $rows = array();
        foreach ($this->getRows() as $row) {
            if ($user->getId()->isEqualTo(new UserId($row['id']))) {
                continue;
            }

            $rows[] = $row;
        }

        file_put_contents($this->filename, Yaml::dump($rows));
    }

    private function getRows()
    {
        return Yaml::parse($this->filename) ?: array();
    }
}
```

This new repository relies on two **Symfony2 components**:
[Filesystem](http://symfony.com/doc/current/components/filesystem.html) and
[Yaml](http://symfony.com/doc/current/components/yaml/introduction.html).

As you might notice, the identity between two **users** is checked by the
`isEqualTo()` method, part of the `UserId` value object. The body of this method
is pretty straightforward:

``` php
public function isEqualTo(UserId $userId)
{
    return $this->getValue() === $userId->getValue();
}
```

Register the new repository into the **D**ependency **I**njection **C**ontainer
(DIC).
The `YamlUserRepository` class takes a filename as first argument, that is why
the service definition contains a `<argument>` tag.

The file will be created into the cache directory (`%kernel.cache_dir%`) meaning
that if you clear the cache, your data will be lost.

``` xml
<!-- src/Acme/CoreDomainBundle/Resources/config/repositories.xml -->
<?xml version="1.0" ?>
<container xmlns="http://symfony.com/schema/dic/services"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://symfony.com/schema/dic/services http://symfony.com/schema/dic/services/services-1.0.xsd">

    <parameters>
        <!-- ... -->
        <parameter key="user_repository.yaml.class">Acme\CoreDomainBundle\Repository\YamlUserRepository</parameter>
    </parameters>

    <services>
        <!-- ... -->

        <!-- Concrete Implementations -->
        <service id="user_repository.yaml" class="%user_repository.yaml.class%" public="false">
            <argument>%kernel.cache_dir%/users.yml</argument>
        </service>
    </services>
</container>
```

Using the `YamlUserRepository` rather than the `InMemoryUserRepository` is just
a matter of configuration. Change the **alias** for the `user_repository`
service and you are done:

``` xml
<service id="user_repository" alias="user_repository.yaml"></service>
```

Looks good? **No!** I told you that the implementation worked fine, did you
trust me? You should not, and you should write tests instead.


## Unit Testing

Testing the `YamlUserRepository` implementation looks pretty easy, except that
it relies on the filesystem to load and store data. Most of the developers I
know would `touch` a temporary file at the beginning of each test method and
delete it at the end. That is **not** the right way to test such a thing.

[vfsStream](https://github.com/mikey179/vfsStream) to the rescue! It is a stream
wrapper for a virtual filesystem, which can be used to mock the real filesystem.
That is exactly what you need.

Install it as a `dev` package:

    $ composer require mikey179/vfsStream:"1.3.*@dev" --dev

First, you need to setup the virtual filesystem using the `vfsStream::setup()`
method. Then, you can create a virtual filename that will be injected into your
`YamlUserRepository` just like the DIC would do it:

``` php
<?php

namespace Acme\CoreDomainBundle\Tests\Repository;

use org\bovigo\vfs\vfsStream;
use Acme\CoreDomainBundle\Repository\YamlUserRepository;
use Acme\CoreDomainBundle\Tests\TestCase;
use Acme\CoreDomain\User\User;
use Acme\CoreDomain\User\UserId;

class YamlUserRepositoryTest extends TestCase
{
    private $cacheDir;

    private $repository;

    protected function setUp()
    {
        $this->cacheDir   = vfsStream::setup('cache');
        $this->repository = new YamlUserRepository(vfsStream::url('cache/users.yml'));
    }
}
```

The following method creates fixtures that will be useful in your test methods:

``` php
<?php

class YamlUserRepositoryTest extends TestCase
{

    // ...

    protected function addUsers()
    {
        $this->repository->add(
            new User(new UserId('62A0CEB4-0403-4AA6-A6CD-1EE808AD4D23'), 'Jean', 'Bon')
        );
        $this->repository->add(
            new User(new UserId('62A0CEB4-0403-4AA6-A6CD-1EE808AD4D44'), 'John', 'Doe')
        );
    }
}
```

And here are your first tests:

``` php
<?php

class YamlUserRepositoryTest extends TestCase
{

    // ...

    public function testFind()
    {
        $this->addUsers();

        $user = $this->repository->find(
            new UserId('62A0CEB4-0403-4AA6-A6CD-1EE808AD4D23')
        );

        $this->assertNotNull($user);
        $this->assertInstanceOf('Sportbook\CoreDomain\User\User', $user);
        $this->assertEquals('Jean', $user->getName()->getFirstName());
    }

    public function testFindReturnsNullIfNotFound()
    {
        $user = $this->repository->find(
            new UserId('62A0CEB4-0403-4AA6-A6CD-1EE808AD4D23')
        );

        $this->assertNull($user);
    }

    public function testAdd()
    {
        $this->addUsers();
        $expected = <<<YAML
-
    id: 62A0CEB4-0403-4AA6-A6CD-1EE808AD4D23
    first_name: Jean
    last_name: Bon
-
    id: 62A0CEB4-0403-4AA6-A6CD-1EE808AD4D44
    first_name: John
    last_name: Doe

YAML;
        $this->assertEquals(
            $expected,
            $this->cacheDir->getChild('users.yml')->getContent()
        );
    }
}
```

Note that the `testAdd()` method is just an example on how to use vfsStream.
Also, I won't cover all tests that should be written for this repository, however
you must test all its public methods.

Now, let's setup the functional tests.


## Functional Testing

A while ago, I created a bundle named
[BazingaRestExtraBundle](https://github.com/willdurand/BazingaRestExtraBundle),
which contains various tools that are not part of the
[FOSRestBundle](https://github.com/FriendsOfSymfony/FOSRestBundle) (yet).
One of the most useful class is the `WebTestCase` which extends the Symfony one,
and provides methods that I use all the time while testing REST APIs, especially
the `assertJsonResponse()` I [already
covered](/2012/08/02/rest-apis-with-symfony2-the-right-way/#testing).

Require it as `dev` package:

    $ composer require willdurand/rest-extra-bundle:"0.0.*" --dev

Then, create your first functional test class:

``` php
<?php

namespace Acme\ApiBundle\Tests\Controller;

use Bazinga\Bundle\RestExtraBundle\Test\WebTestCase;

class UserControllerTest extends WebTestCase
{
    public function testAll()
    {
        $client   = static::createClient();
        $crawler  = $client->request('GET', '/users.json');
        $response = $client->getResponse();

        $this->assertJsonResponse($response);
    }
}
```

This test should fail because you didn't provide any fixtures. Use the
`setUp()` method to copy a fixtures file to the cache directory so that you
keep control over the data in your tests:

``` php
<?php

class UserControllerTest extends WebTestCase
{
    // ...

    protected function setUp()
    {
        $this->client = static::createClient();

        (new Filesystem())->copy(
            __DIR__ . '/../Fixtures/users.yml',
            $this->client->getContainer()->get('kernel')->getCacheDir() . '/users.yml',
            true
        );
    }
}
```

The `Fixtures/users.yml` file contains the following data:

``` yaml
-
    id: 50AAF29D-DB0B-43FE-9DD8-2F1C058416C5
    first_name: Jean
    last_name: Bon
-
    id: 53E2F088-E0B0-4A21-86A8-67B2FD6A2749
    first_name: John
    last_name: Doe
```

That's it! You are able to test your application in a functional way like a
boss!


## Conclusion

As of now, the sample application looks good. It does not do much things right
now, but everything is bootstrapped. You should keep in mind that testing is
really important, and that you should use the right tools even in your tests.
[vfsStream](https://github.com/mikey179/vfsStream) is awesome!

Hopefully you now understand why combining programming to the interface with
dependency injection is powerful. Replacing an implementation to another one is
just a matter of alias here.

In the next blog post, I will mainly cover **factories**, stay tuned!
