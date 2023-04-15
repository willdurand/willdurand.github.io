---
layout: post
title: On being a .NET developer for a weekend
location: Zürich, Switzerland
updates:
  - date: 2023-04-15
    content: I proofread this article and fixed some links.
redirect_from:
  - /2013/05/09/being-a-net-developer-for-a-weekend/
---

Even though I learned C# and the .NET platform at the University, I only started
to get exposed to all these Microsoft technologies some weeks ago. My current
job is somewhat tied to software built with the .NET platform.

To be honest, I had tons of preconceived ideas about Microsoft and its
programming technologies. One of them was the fact that [you can certainly build
open source software in .NET. And many do. But it never feels natural. It never
feels right. \[...\] It is just not a native part of the Microsoft .NET culture
to make things open source, especially not the things that
suck](https://blog.codinghorror.com/why-ruby/).

However, I always considered Visual Studio to be one of the best IDEs (as much
as I love _vim_, I don't think that's an IDE).

## The plan

I decided to rewrite [TravisLight](https://github.com/willdurand/TravisLight), a
weekend project I introduced in [a previous "On being a _XXX_ developer for a
weekend" article](/2012/12/24/on-being-a-frontend-developer-for-a-weekend/). My
goals were to learn [Windows Presentation
Foundation](http://msdn.microsoft.com/en-us/library/aa970268.aspx) (WPF), the
[Model-View-ViewModel](https://en.wikipedia.org/wiki/Model_View_ViewModel)
design pattern, and to become familiar with some more Microsoft tools.

The codename of my project is TravisLight.Net. It is released under the MIT
license and publicly available on CodePlex, Microsoft's open source project
hosting platform. CodePlex is more or less GitHub for .NET developers. It offers
both [Git](https://git-scm.com/) and [Team Foundation
Server](https://en.wikipedia.org/wiki/Team_Foundation_Server) (TFS)
repositories.

## Team Foundation Server

TFS is not only a source code management system but also a complete
collaboration platform including an issue-tracking system and a build server
(among other things). To me, this looks like to
[SVN](https://subversion.apache.org/) with superpowers. Yes, it's a centralized
version control system!

Compared to Git, I miss the staging area and the disconnected mode. Creating
beautiful changesets[^1] is not super easy either, and I'd also add that locking
files to edit them is a pain.

[^1]: A "changeset" in TFS is similar to a "commit" in SVN.

Most things happening in Team Foundation Server are centered around "work
items". It is (more or less) like an issue (or bug) in some other bug tracker.
For each changeset, one can attach one or more work items. This is actually
cool.

The next step to build TravisLight.Net was to organize my code. I decided to
follow the MVVM pattern.

## Model-View-ViewModel

The **M**odel-**V**iew-**V**iew **M**odel (MVVM) design pattern is used to
separate the business and presentation layers of an application from its user
interface. Both the Model and the View layers are the same as in the
**M**odel-**V**iew-**C**ontroller (MVC) design pattern. However, the View is not
aware of the Model, and vice-versa.

The ViewModel layer acts as the glue between the Model and the View. The
ViewModel also exposes methods and/or commands that help to maintain the state
of the View and to manipulate the Model as the result of actions on the View.

The View and the ViewModel rely on data-binding and commands to communicate.
[Data binding](https://msdn.microsoft.com/en-us/library/ms752347.aspx) is the
process that establishes a connection between the user interface and business
logic. When the data changes its value, the elements that are bound to the data
reflect changes automatically.

In Visual Studio, I created a "solution" with one "project" per layer. A
solution is a container for projects, and a project can be seen as a component
of an application. A project for each layer seemed like a good idea to me
(separation of concerns FTW).

Now, TravisLight.Net is a desktop application that displays build statuses from
[Travis-CI](https://travis-ci.org). This service provides a REST API that
returns JSON data. What do we need? A library to manipulate JSON data of course.
Where/how do we find that? [NuGet](https://www.nuget.org/) to the rescue!

## Introducing NuGet

[NuGet](https://www.nuget.org/) (pronounced "New Get" and not "Nugget") is a
fantastic Visual Studio extension that makes it easy to install and update
third-party libraries and tools. This is a package manager for .NET developers.
At the time of writing, there are more than 11600 packages, including many of
the Microsoft libraries!

I decided to [use NuGet without committing packages to source
control](http://docs.nuget.org/docs/workflows/using-nuget-without-committing-packages),
which seemed to be a good idea. Visual Studio automatically downloaded the
missing packages before building the project.

Now that I have introduced some tools and concepts, let's focus on some
implementation details.

## Working with JSON

I used [Json.NET](https://www.newtonsoft.com/json), a powerful JSON framework
for .NET, to manipulate JSON data. And to be honest, deserializing data could
not be easier.

The `DeserializeObject()` method takes a string as argument, and returns an
object. This is a generic method so one can specify the object's type they
expect to get:

```csharp
using Newtonsoft.Json;
using TravisLight.Model.Entity;
...

List<Repo> repositories = JsonConvert.DeserializeObject<List<Repo>>(json);
```

Json.NET automatically maps a JSON key to a property in the C# class. If we want
to define our own mapping, we can add a `JsonProperty` annotation to the
properties. In the following code, the `Id` property is automatically mapped to
an `id` entry in JSON and the `LastBuildResult` property is explicitely mapped
to a `last_build_result` entry in JSON:

```csharp
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

```json
[
  { "id": 123, "last_build_result": null },
  { "id": 123, "last_build_result": "2012-06-21T12:00:59Z" }
]
```

## The nullable type

You may have noticed the use of a `Nullable<T>` type above. The API may or may
not return a value for the `last_build_result` entry. If a value is provided, it
is a `boolean`, otherwise it is `null`. The [Nullable
type](https://msdn.microsoft.com/library/1t3y8s4s.aspx) allows to either have a
value or none.

```csharp
if (LastBuildResult.HasValue)
{
    return LastBuildResult.Value ? Status.Failed : Status.Passed;
}
```

As we can see in the example above, it is really expressive. It is worth
mentioning that the C# language is feature-rich:
[generics](https://msdn.microsoft.com/library/512aeb7t.aspx), [extension
methods](https://msdn.microsoft.com/library/bb383977.aspx),
[reflection](https://msdn.microsoft.com/library/ms173183.aspx),
[LINQ](https://msdn.microsoft.com/library/bb397926.aspx), [lambda
expressions](https://msdn.microsoft.com/library/bb397687.aspx), [asynchronous
programming](https://msdn.microsoft.com/library/hh191443.aspx), and a lot more!

## LINQ and lambda expressions on collections

**L**anguage-**IN**tegrated**Q**uery also known as
[LINQ](https://msdn.microsoft.com/library/bb397926.aspx) extends powerful query
capabilities to the language syntax of C#. This works with `DataSet`, XML and
objects such as `List<T>`.

I used LINQ to sort the repositories according to a rank (i.e. according to the
build statuses, the failing projects come first) in the `ApiRepository`:

```csharp
return repositories.OrderBy(repository => repository.Rank).ToList();
```

In the code snippet above, the `=>` sign represents a lambda expression which is
also known as a closure (an anonymous function with a context).

## Meet the layers

I only covered the Model layer until now so let's talk about the View and the
ViewModel layers.

The View has been written in
[XAML](https://msdn.microsoft.com/en-us/library/ms752059.aspx). It is a
declarative markup language with a large set of components to build graphical
user interfaces.

In TravisLight.Net, there is a single window (`MainWindow`) that displays a
single "UserControl" named `ListView`. This view renders the list of
repositories with their status thanks to the `ListViewModel`.

The `ListViewModel` receives an instance of `IRepository` as constructor's
argument, and creates an
[`ObservableCollection`](https://msdn.microsoft.com/en-us/library/ms668604.aspx)
containing the repositories. This ViewModel is also responsible for refreshing
this collection (using a timer for now).

## Dependency inversion principle

By following the MVVM pattern, I ended up with a well-decoupled application, and
it was worth using programming to the interface as well as a Dependency
Injection Container. It was particularly useful for testing (which we will see
in a moment).

Microsoft provides a library called
[Unity](https://msdn.microsoft.com/en-us/library/ff647202.aspx) that is a
lightweight, and extensible Dependency Injection Container. We can configure
this container either in XML or C#.

A common pattern with MVVM seems to be the use of a Bootstrapper, i.e. a class
that prepares the container before starting the application. Mine looks like
this:

```csharp
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

As we can see, it also contains a `Main()` method. That is the entry point of
the application. Unity is configured in the constructor and the `Run()` method
passes the `MainWindow` to the application.

## Unit testing

Microsoft maintains MSTest, a unit testing framework. As usual, it is
well-integrated with Visual Studio and TFS.

That being said, I didn't quite like its syntax, it is not super expressive.
Fortunately, I found another unit testing framework named
[NUnit](https://www.nunit.org/). Much better in my opinion!

```csharp
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

Each assertion is close to an actual sentence in plain English:

    Assert that [the] repositories [collection] has count equal to 1.

In the code above, you may have noticed the `TestFixtureSetUp()` method I used
to inject a mocked instance of `IRepository` instead of the `ApiRepository`
implementation. Thanks, Dependency Injection!

## Conclusion

Yet another great moment! This weekend project was a nice experience and I
learned a lot.

Microsoft has pretty good tools/technologies these days, though they require
Windows. I should probably look at
[Mono](https://www.mono-project.com/CSharp_Compiler), but there is no support
for C# 4.5 yet.

As for the future, I still have thing I'd like to explore, e.g. [Entity
Framework](https://msdn.microsoft.com/en-us/data/ef.aspx) and the [Stack
Exchange Open Source
projects](https://blog.stackoverflow.com/2012/02/stack-exchange-open-source-projects/)
😇
