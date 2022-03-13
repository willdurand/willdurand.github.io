---
layout: post
title: Deploying with Git
location: Clermont-Fd Area, France
updates:
  - date: 2022-03-12
    content: I proofread this article and removed dead links.
---

I often rely on [Capistrano](https://github.com/capistrano/capistrano/wiki/) to
deploy web applications. I already talked about this tool in my previous blog.
In this article, I am going to describe a simpler approach to deploy simple
apps.

When you need to deploy a simple web application on a server, like this blog for
instance, there is no need to use Capistrano or [Fabric][]. We mainly want a way
to copy a set of files and one could rely on `rsync` or `scp`... How boring!

An alternative is to rely on **Git**, assuming you are using it. But how?

The first step is to configure the local repository by adding a new remote:

    git remote add -t master production ssh://<server>/path/to/project_prod

The `-t <branch>` option allows to track a given branch instead of all branches.
You can add more remotes if you want, like a `testing` remote for instance:

    git remote add testing ssh://<server>/path/to/project_test

To deploy the application to **production**, run:

    git push production

To deploy the application to a **testing** environment, run:

    git push testing <branch>

At the moment, you can push your code to your server but it won't deploy your
changes. We need to configure Git. First, add the following lines to the
`.git/config` file:

```gitconfig
[receive]
    denyCurrentBranch = false
```

This allows to push code to the current branch, which is important to deploy
your new changes. Old Git versions don't need to set this parameter by the way.

Then, create and enable a `post-receive` hook with the following content:

```bash
#!/usr/bin/env bash

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
```

This script updates the working tree after changes have been pushed, and send an
email to the last committer. Keep in mind that it always deploys the last branch
you push.

The important part is:

```bash
cd ..
env -i git checkout $branch
env -i git reset --hard
```

Feel free to "decorate" these three lines as you wish.

For example, for the **production** environment (or because you are using a [Git
Branching Model](/2012/01/17/my-git-branching-model/)), you should modify the
previous script to make sure that you only deploy the `master` branch:

```bash
    if [ "$branch"  == "master" ] ; then
        cd ..
        # env -i git checkout $branch
        env -i git reset --hard

        # Send an email
    fi
```

You're done! Each time you'll execute `git push production`, you'll deploy your
application to your production environment. Easy. Fast. Powerful.

[fabric]: https://docs.fabfile.org/
