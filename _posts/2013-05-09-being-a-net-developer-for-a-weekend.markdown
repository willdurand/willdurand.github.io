---
layout: post
title: Being A .NET Developer For A WeekEnd
location: Zürich, Switzerland
---

Even if I learnt C# and the .NET platform at school, I really started playing
with all these Microsoft things a few weeks ago. My job is sort of related to
the .NET platform, so I decided to look at this ecosystem.

To be honest, I had tons of preconceived ideas about Microsoft and its
programming technologies. One of them was the fact that [you can certainly build
open source software in .NET. And many do. But it never feels natural. It never
feels right. \[...\] It is just not a native part of the Microsoft .NET culture to
make things open source, especially not the things that
suck](http://www.codinghorror.com/blog/2013/03/why-ruby.html).

However, I always considered Visual Studio as the best IDE ever. It integrates
everything you need while programming. And it just works (as much as I love
_vim_, it's not an IDE).


## The Plan

I decided to rewrite [TravisLight](https://github.com/willdurand/TravisLight), a
weekend project I covered in [a previous "Being a _X_ Developer For A
WeekEnd" article](/2012/12/24/being-a-frontend-developer-for-a-weekend/). My
goal was to learn [Windows Presentation
Foundation](http://msdn.microsoft.com/en-us/library/aa970268.aspx) (WPF), the
[Model-View-ViewModel](http://en.wikipedia.org/wiki/Model_View_ViewModel)
design pattern, and to become familiar with a few Microsoft tools.

The project name is: [TravisLight.Net](http://travislightnet.codeplex.com/). It
is released under the MIT license, and publicly available on
[CodePlex](http://www.codeplex.com/), the Microsoft's open source project hosting
web site. CodePlex could be seen as a GitHub for .NET developers. It offers
[Git](http://git-scm.com/) and [Team Foundation
Server](http://en.wikipedia.org/wiki/Team_Foundation_Server) (TFS) repositories
for your .NET Open Source projects.


## Team Foundation Server

TFS is not only a source code management system but also a complete
collaboration platform including an issue-tracking system, a build server, and
so on. To me, it looks like [SVN](http://subversion.apache.org/) with
superpowers. Yes, it's a **centralized** version control system!

I decided to give it a try. Ok, this was a bad idea. I missed the Git staging
area, and the disconnected mode. Creating beautiful **changesets** is not easy.
And locking files in order to edit them is a pain.
By the way, a "changeset" in TFS is a "commit" in SVN. Oh, and we don't
"commit" in TFS, we "check-in".

Most activity in Team Foundation Server revolves around a **work item**. It is
(more or less) like an **issue** or a **bug** in your favourite issue tracker.
For each changeset, you can attach one or more work items. This is actually
cool.

The next step was to know how to organize my code. I decided to follow the MVVM
pattern.


## Model-View-ViewModel

The **M**odel - **V**iew - **V**iew **M**odel (MVVM) design pattern helps you
separate the business and presentation logic of your application from its user
interface. Both the Model and the View layers are the same as in the
**M**odel - **V**iew - **C**ontroller (MVC) design pattern. However, the View is
not aware of the Model, and vice-versa.

![](http://i.msdn.microsoft.com/dynimg/IC448690.png)

The **ViewModel** layer acts as the glue between the Model and the View. The
ViewModel also exposes methods and/or commands that help maintain the state of
the View, and manipulate the Model as the result of actions on the View.

The View and the ViewModel rely on **data-binding** and commands to communicate.
[Data binding](http://msdn.microsoft.com/en-us/library/ms752347.aspx) is the
process that establishes a connection between the user interface and business
logic. When the data changes its value, the elements that are bound to the data
reflect changes automatically.

I created a **solution** with one **project** per layer. Visual Studio provides
two containers to manage your code. A solution is a container for projects, and
a project can be seen as a component of your application. It seems like a good
idea to have a project for each layer as it ensures the separation of concerns.

Now, let's go back to the application itself. TravisLight.Net is a port of
[TravisLight](http://williamdurand.fr/TravisLight/). It is a desktop application
that displays build statuses from [Travis-CI](http://travis-ci.org). This
service provides a [REST API](https://api.travis-ci.org/docs/) that returns JSON
data.

To sum up, I needed a library to manipulate JSON data, and a way to perform
requests. I googled these terms, and found something **really** awesome:
[NuGet](http://nuget.org/).


## Introducing NuGet

[NuGet](http://nuget.org/) (pronounced "New Get" and not "Nugget") is a
fantastic Visual Studio extension that makes it easy to install and update
third-party libraries and tools. Yes, a **package manager** for .NET developers.
There are more than 11600 packages, including the Microsoft libraries!

I decided to [use NuGet without committing packages to source
control](http://docs.nuget.org/docs/workflows/using-nuget-without-committing-packages)
which seems to be a good idea. Visual Studio will automatically download the
missing packages before building your project, just like you would do in Ruby,
PHP, etc.

Now that I have introduced some tools and concepts, let's focus on some
implementation details.


## Working With JSON

I chose [Json.NET](http://james.newtonking.com/projects/json-net.aspx), a
powerful JSON framework for .NET, to manipulate JSON data. And to be honest,
deserializing data could not be easier.

The `DeserializeObject()` method takes a string as argument, and returns an
object. This is a **generic method** so you can specify the object's type you
want to get:

``` csharp
using Newtonsoft.Json;
using TravisLight.Model.Entity;
...

List<Repo> repositories = JsonConvert.DeserializeObject<List<Repo>>(json);
```

Json.NET automatically maps a key in the JSON to a property in the C# class. If
you want to define your own mapping, you can add a `JsonProperty` annotation to
your properties. In the following code, the `Id` property is automatically
mapped to an `id` entry in JSON, and the `LastBuildResult` property is
explicitely mapped to a `last_build_result` entry in JSON:

``` csharp
using Newtonsoft.Json;
using System;

namespace TravisLight.Model.Entity
{
    public class Repo
    {
        #region properties

        public int Id
        {
            get;
            set;
        }

        ...

        [JsonProperty("last_build_result")]
        public Nullable<bool> LastBuildResult
        {
            get;
            set;
        }

        #endregion
    }
}
```

These two code snippets above are enough to deserialize the following JSON
content:

``` json
[
    { "id": 123, "last_build_result": null },
    { "id": 123, "last_build_result": "2012-06-21T12:00:59Z" }
]
```


## The Nullable Type

You may have noticed the use of a `Nullable<T>` type, did you? The API may or
may not return a value for the `last_build_result` entry. If a value is
provided, it is a `boolean`, otherwise it is `null`. The [Nullable
type](http://msdn.microsoft.com/library/1t3y8s4s.aspx) allows to either
have a value or none.

``` csharp
if (LastBuildResult.HasValue)
{
    return LastBuildResult.Value ? Status.Failed : Status.Passed;
}
```

As you can see in the example above, it is really expressive. It is worth saying
the C# language is feature-rich:
[generics](http://msdn.microsoft.com/library/512aeb7t.aspx),
[extension methods](http://msdn.microsoft.com/library/bb383977.aspx),
[reflection](http://msdn.microsoft.com/library/ms173183.aspx),
[LINQ](http://msdn.microsoft.com/library/bb397926.aspx),
[lambda expressions](http://msdn.microsoft.com/library/bb397687.aspx),
[asynchronous
programming](http://msdn.microsoft.com/library/hh191443.aspx),
and a lot more!


## LINQ And Lambda Expressions On Collections

**L**anguage - **IN**tegrated **Q**uery also known as
[LINQ](http://msdn.microsoft.com/library/bb397926.aspx) extends powerful
query capabilities to the language syntax of C#. This works with `DataSet`, XML
and objects such as `List<T>`.

I used LINQ to sort the
[repositories](http://travislightnet.codeplex.com/SourceControl/latest#481514)
according to a rank (i.e. according to the build statuses, the failing projects
come first) in the
[`ApiRepository`](http://travislightnet.codeplex.com/SourceControl/latest#481515):

``` csharp
return repositories.OrderBy(repository => repository.Rank).ToList();
```

In the code above, the `=>` sign represents a lambda expression which is also
known as a closure (an anonymous function with a context).


## Meet The Layers

I only covered the **Model** layer until now, let's talk about the **View**
and the **ViewModel** layers.

The **View** has been written in
[XAML](http://msdn.microsoft.com/en-us/library/ms752059.aspx). It is a
declarative markup language with a large set of components to build graphical
user interfaces.

In TravisLight.Net, there is a single window (`MainWindow`) that displays a
single **UserControl** named
[`ListView`](http://travislightnet.codeplex.com/SourceControl/latest#481390).
This view renders the list of repositories with their status thanks to the
[`ListViewModel`](http://travislightnet.codeplex.com/SourceControl/latest#481391).

The `ListViewModel` receives an instance of `IRepository` as constructor's
argument, and creates an
[`ObservableCollection`](http://msdn.microsoft.com/en-us/library/ms668604.aspx)
containing the repositories. This ViewModel is also responsible for refreshing
this collection, using a timer for now.


## Dependency Inversion Principle

By following the **MVVM** pattern, you ends up with a well-decoupled
application, and it is worth using **programming to the interface** as well as a
**Dependency Injection Container**. It is particularly useful for testing, and
we will see that part later on.

Microsoft provides a library called
[Unity](http://msdn.microsoft.com/en-us/library/ff647202.aspx) that is a
lightweight, and extensible Dependency Injection Container. You can configure
this container either in XML, or C#.

A common pattern using MVVM seems to be the use of a **Bootstrapper**, a class
that triggers the container in order to start the application. Mine looks like
this:

``` csharp
namespace TravisLight.Main
{
    class Bootstrapper
    {
        #region attributes

        private IUnityContainer container = new UnityContainer();

        #endregion

        public Bootstrapper()
        {
            container.RegisterType<IRepository, ApiRepository>();
            container.RegisterType<ListViewModel, ListViewModel>();
            container.RegisterType<ListView, ListView>();
            container.RegisterType<MainWindow, MainWindow>();
        }

        public void Run()
        {
            Application app = new App();
            app.Run(container.Resolve<MainWindow>());
        }

        [STAThread]
        static void Main()
        {
            Bootstrapper bootstrapper = new Bootstrapper();
            bootstrapper.Run();
        }
    }
}
```

As you can see, it also contains a `Main()` method which is the **entry point**
of the application (it is not a web application here). **Unity** is configured
in the constructor, and the `Run()` method just passes the `MainWindow` to the
application.


## Unit Testing

Microsoft provides **MSTest**, its own unit testing framework. As usual, it is
well-integrated in Visual Studio, TFS, and so on. It looks good. Well, which
unit testing framework isn't cool anyway?

However, I don't like its syntax, it is not really expressive. Fortunately,
there is another unit testing framework called [NUnit](http://www.nunit.org/) that
is really expressive:

``` csharp
namespace ViewModel.Test
{
    [TestFixture]
    public class ListViewModelTest
    {
        private IUnityContainer container;

        [TestFixtureSetUp]
        public void TestFixtureSetUp()
        {
            container = new UnityContainer();
            container.RegisterType<ListViewModel, ListViewModel>();
            container.RegisterType<IRepository, Mock.Repository>();
        }

        [Test]
        public void TestRepositoriesProperty()
        {
            ListViewModel listViewModel = container.Resolve<ListViewModel>();

            Assert.That(listViewModel.Repositories, Has.Count.EqualTo(1));
            Assert.That(listViewModel.Repositories, Has.All.InstanceOf<Repo>());
        }
    }
}
```

As you can read, it is really close to a real sentence:

    Assert that [the] repositories [collection] has count equal to 1.

In the code above, you may have noticed the `TestFixtureSetUp()` method I used
to inject a mocked instance of `IRepository` instead of the `ApiRepository`
implementation.


## Conclusion

I enjoyed playing with all these new toys. It was a great experience as I learnt
a lot, and I must admit, Microsoft has interesting tools/technologies these
days. I am not fan of using a PC with Windows to develop though...

I should probably look at [Mono](http://www.mono-project.com/CSharp_Compiler),
but there is no support for C# 4.5 yet. I have tons of other things to explore
such as [Entity Framework](http://msdn.microsoft.com/en-us/data/ef.aspx), or
the [Stack Exchange Open Source
projects](http://blog.stackoverflow.com/2012/02/stack-exchange-open-source-projects/).


## TL;DR

* Avoid **TFS**, prefer **Git** instead
* Use **NuGet**, always!
* **MVVM** is a great pattern
* Use **Unity** or **MEF**
* Prefer **NUnit** over MSTest
* The Microsoft world is quite cool actually!
