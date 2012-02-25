---
layout: post
title: Deploying With Git
location: Clermont-Fd Area, France
---

Yeah, I know yet another blog post on this topic. The main difference with
others is that I wrote it myself, and it's quite up to date.

I often rely on [Capistrano](https://github.com/capistrano/capistrano/wiki/) to
deploy web applications.
I ever talked about this tool [in my previous blog](http://www.willdurand.fr/deploiement-automatise-avec-capistrano-et-git-pour-symfony-et-diem/),
and it's not the purpose of this article.

Actually, when you need to deploy a simple web application on a server, like this
blog for instance, there is no need to use Capistrano or [Fabric](http://docs.fabfile.org/en/1.4.0/index.html).
You just need to copy files. So you could rely on `rsync`... But it's not fun!

Actually, you just need to rely on **Git**, assuming you are using it.

The first step is to configure your local repository by adding a new remote:

    git remote add -t master production ssh://<server>/path/to/project_prod

The `-t <branch>` option allows you to track a given branch instead of all branches.
You can add more remotes if you want like a `testing` remote.

    git remote add testing ssh://<server>/path/to/project_test

To deploy the application in **production**, run:

    git push production

And, to deploy in a **testing** environment, just run:

    git push testing <branch>

You can push your code on your server, but it won't deploy new changes at the moment.
So let's configuring **Git**. First, add the following lines to your `.git/config` file:

{% highlight bash %}
[receive]
    denyCurrentBranch = false
{% endhighlight %}

It allows to push code on the current branch, it's important to deploy new changes.
Old Git versions don't need to set this parameter by the way.

Then, enable a `post-receive` hook with the following content:

{% highlight bash %}
#!/bin/sh

SUBJECT="Deploy successful"
BODY="You've successfully deployed the branch:"

while read oldrev newrev ref
do
    branch=`echo $ref | cut -d/ -f3`

    if [ "$branch" ] ; then
        cd ..
        env -i git checkout $branch
        env -i git reset --hard

        EMAIL=`env -i git log -1 --format=format:%ae HEAD`
        BODY="$BODY $branch."

        echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"
    fi
done
{% endhighlight %}

This script updates the working tree after changes have been pushed, and send an email to the
last committer. Keep in mind that it always deploys the last branch you push.

The important part is:

{% highlight bash %}
cd ..
env -i git checkout $branch
env -i git reset --hard
{% endhighlight %}

Feel free to decorate these three lines as you want.

In a **production** environment, or because you are using a [Git Branching Model](/2012/01/17/my-git-branching-model/),
you should modify the previous code as below. It ensures to always deploy the `master` branch:

{% highlight bash %}
    if [ "$branch"  == "master" ] ; then
        cd ..
        env -i git reset --hard

        // Send an email
    fi
{% endhighlight %}

You're done, each time you'll run a `git push production`, you'll deploy your application in production.

Easy. Fast. Powerful.
