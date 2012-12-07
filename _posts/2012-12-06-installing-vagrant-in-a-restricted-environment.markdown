---
layout: post
title: Installing Vagrant In A Restricted Environment
location: Clermont-Fd Area, France
---

Lately, I worked on installing [Vagrant](http://vagrantup.com/) in a restricted
environment. By "restricted environment", I mean an infrastructure with
restricted permissions for our users, disk quotas, NFS volumes, and a stable
operating system: Debian Squeeze32. This work has been done in collaboration
with the sysadmin of my University.


## Installation

Vagrant needs VirtualBox 4.0 or upper, but the latest [VirtualBox version
available for Debian stable](http://wiki.debian.org/VirtualBox) is
3.2.10 OSE. Fortunatelly, Debian Backports provide VirtualBox 4.0.x:

    # /etc/apt/sources.list
    deb http://backports.debian.org/debian-backports squeeze-backports main

Installing VirtualBox becomes easy:

    apt-get -t squeeze-backports install virtualbox virtualbox-dkms

The `virtualbox-dkms` package is required to compile the module. If you want a
graphical user interface, install `virtualbox-qt`.

Also,if you use a virtualization solution (KVM for instance), you should unload
its module ([rmmod](http://man7.org/linux/man-pages/man2/delete_module.2.html) is
your friend).

Now, let's install Vagrant. Last stable version is 1.0.5, and you can find
packages at:
[http://downloads.vagrantup.com/tags/v1.0.5](http://downloads.vagrantup.com/tags/v1.0.5).

    wget http://files.vagrantup.com/packages/be0bc66efc0c5919e92d8b79e973d9911f2a511f/vagrant_1.0.5_i686.deb
    dpkg -i vagrant_1.0.5_i686.deb


## Customizing the default directories

As I said in introduction, users have disk quotas (500Mo) so they can't use
Vagrant for two reasons:

* VirtualBox stores its VMs in `~/VirtualBox VMs/`;
* Vagrant stores its boxes in `~/.vagrant.d/`.

The solution is to change these two directories. Thanksfully, Vagrant provides a
`VAGRANT_HOME` environmental variable so you can easily change the Vagrant
directory:

    export VAGRANT_HOME=/path/to/vagrant

In our case, we used `/usr/local/vagrant` as main Vagrant directory, and we set
it for all users. That allowed us to import a set of boxes for our users.

Let's do the same thing for VirtualBox! Err... no. There is no environmental
variable defined for VirtualBox, but we can still configure VirtualBox using
`vboxmanage`:

    vboxmanage setproperty machinefolder /path/to/virtualbox

[VBoxManage
setproperty](http://www.virtualbox.org/manual/ch08.html#vboxmanage-setproperty)
is useful to change global settings. The command above changes the default
machine folder (`~/VirtualBox VMs` by default).

We made a tiny shell script named `vagrant` and located in the `PATH` of our users
to run this command and to forward the eventual arguments to Vagrant. The reason
is quite simple, there is no way to run VBoxManage using Vagrant before everything
else. I opened an issue for that
([#1247](https://github.com/mitchellh/vagrant/issues/1247)).

To avoid conflicts, you can use `$USER` to define one machine folder per user:

    vboxmanage setproperty machinefolder "/usr/local/virtualbox/$USER"

So far so good, our users can run Vagrant to install VMs.


## The `initramfs` prompt (of death)

We tried the _lucid32_ Vagrant box, which is an [official
box](https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Boxes), but it
didn't work. This was an issue related to the box itself. VirtualBox couldn't
boot it, an `initramfs` prompt was displayed. Most of the time, this appears
because no disk can be found.

That's why we tried to change the disk controller, we removed the SATA
controller and attached the disk to the IDE controller. With this configuration,
we were able to boot the image, and to log in. [This was been
reported](https://github.com/mitchellh/vagrant/issues/884#issuecomment-10857450)
as well.

So the fix was to switch from a SATA controller to an IDE controller. It can be
done using VBoxManage:

    vboxmanage storagectl <UUID> --name "SATA Controller" --remove
    vboxmanage storageattach <UUID> --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium /path/to/box-disk1.vmdk

Vagrant provides a way to [customize a
VM](http://vagrantup.com/v1/docs/config/vm/customize.html) thanks to the
`config.vm.customize` parameter:

    config.vm.customize ["modifyvm", :id, "--memory", 1024]

However, we decided to patch the boxes instead of using this parameter. One
reason was that we didn't know how to get the path to the `vmdk` file.

We were able to boot a `lucid32` VM, but a new issue appeared: NFS. In order to
share the current working directory with the VM, we used this configuration in
the `Vagrantfile`:

    config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)

It worked fine without NFS set to `true` but it was quite slow. Thus, NFS was a
requirement.


## The Surprise

<blockquote class="twitter-tweet tw-align-center">
<p>So everybody uses <a href="https://twitter.com/search/%23vagrant">#vagrant</a> now, and nobody cares about `sudo su root`? WTF! <a href="https://t.co/ioVsrBqx" title="https://github.com/mitchellh/vagrant/blob/master/plugins/hosts/linux/host.rb#L51">github.com/mitchellh/vagr…</a></p>
&mdash;William DURAND (@couac) <a href="https://twitter.com/couac/status/274191748786429953" data-datetime="2012-11-29T16:43:01+00:00">November 29, 2012</a>
</blockquote>

I dug into the code to understand how NFS was managed, and why it asked for
admin credentials. I was really suprised while reading the code. There is no way
to configure Vagrant to control the NFS part, and sadly it asks for the `root`
password.

There is no way to give the `root` password to our users (mainly students). We
ended up patching Vagrant to use `exportfs` and a shell script to perform `sed`.
`nfsd` is always up so there is no need to restart it, and `exportfs` does
a good job.
As `/etc` is not writable for everyone, we used a shell script to change the
content of `/etc/exports` using a simple `sed -i -e`. And now, both commands
are sudoable.

And, that's it! Our users can use Vagrant as usual.


## Useful Tips

[Debugging Vagrant](http://vagrantup.com/v1/docs/debugging.html) can be really
useful, especially when you start playing with VM customization.
To enable logging, use the `VAGRANT_LOG` environmental variable:

    VAGRANT_LOG=INFO vagrant up


Hardware virtualization **should** be enabled if you want to run 64bits VMs on a
32bits host. The VirtualBox documentation isn't clear about that in the chapter
about [hardware vs software
virtualization](http://www.virtualbox.org/manual/ch10.html#hwvirt).


## Conclusion

Vagrant needs some improvements to be more configurable, and a bit safer in my
opinion. However, it is flexible enough, we can do pretty much whatever
we want with it, and it just works!
