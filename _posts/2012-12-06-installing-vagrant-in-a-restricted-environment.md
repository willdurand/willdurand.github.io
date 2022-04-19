---
layout: post
title: Installing Vagrant in a restricted environment
location: Clermont-Fd Area, France
updates:
  - date: 2022-04-19
    content: I proofread this article and fixed some links.
---

Lately, I had to install [Vagrant][] in a restricted environment. By that, I
mean an infrastructure with restricted permissions for our users, disk quotas,
NFS volumes and a stable operating system: Debian Squeeze32. This work has been
done in collaboration with the sysadmin of my University.

## Installation

At the time of writing, Vagrant needs VirtualBox 4.0 or upper, but the latest
[VirtualBox version available for Debian stable][VirtualBox] is 3.2.10 OSE.
Fortunately, Debian Backports provide VirtualBox 4.0.x:

    # /etc/apt/sources.list
    deb http://backports.debian.org/debian-backports squeeze-backports main

Installing VirtualBox becomes easy:

    apt-get -t squeeze-backports install virtualbox virtualbox-dkms

The `virtualbox-dkms` package is required to compile the module. If you want a
graphical user interface, you should install `virtualbox-qt` too.

Also, if you use a virtualization solution (KVM for instance), you should unload
its module ([`rmmod`(8)][rmmod] is your friend).

Now, let's install Vagrant. Last stable version is 1.0.5, and you can find
packages at: _downloads.vagrantup.com/tags/v1.0.5_ (this link no longer works).

    wget http://files.vagrantup.com/packages/be0bc66efc0c5919e92d8b79e973d9911f2a511f/vagrant_1.0.5_i686.deb
    dpkg -i vagrant_1.0.5_i686.deb

## Customizing the default directories

As I said in the introduction, users have disk quotas (500Mo) and they can't
easily use Vagrant for two reasons:

- VirtualBox stores its VMs in `~/VirtualBox VMs/` by default
- Vagrant stores its boxes in `~/.vagrant.d/` by default

The solution is to change these two directories. Thanksfully, Vagrant provides
a `VAGRANT_HOME` environment variable. You can easily change the default Vagrant
directory with:

    export VAGRANT_HOME=/path/to/vagrant

In our case, we used `/usr/local/vagrant` as the main Vagrant directory and we
set it for all users. That allowed us to import a set of boxes for our users.

Let's do the same thing for VirtualBox! Err... no. There is no environment
variable defined for VirtualBox but we can still configure VirtualBox using
`vboxmanage`:

    vboxmanage setproperty machinefolder /path/to/virtualbox

[VBoxManage setproperty][setproperty] is useful to change global settings. The
command above changes the default machine folder (`~/VirtualBox VMs` by default).

We created a tiny shell script named `vagrant`, located in the `PATH` of our
users, to run this command and then forward the other arguments to Vagrant. The
reason is quite simple, there is no way to run VBoxManage using Vagrant before
everything else. I opened an issue for that (see:
[#1247](https://github.com/mitchellh/vagrant/issues/1247)).

To avoid conflicts, you can use `$USER` to define a machine folder per user:

    vboxmanage setproperty machinefolder "/usr/local/virtualbox/$USER"

So far so good, our users can run Vagrant to install VMs.

## The `initramfs` prompt (of death)

We tried the _lucid32_ Vagrant box, which is an [official box][], but that
didn't work. This was an issue related to the box itself. VirtualBox couldn't
boot it and an `initramfs` prompt was displayed. Most of the time, this prompt
appears because no disk can be found.

That's why we tried to change the disk controller. We removed the SATA
controller and attached the disk to the IDE controller. With this configuration,
we were able to boot the image, and to log in. [This was been
reported](https://github.com/mitchellh/vagrant/issues/884#issuecomment-10857450)
as well.

The "fix" was to switch from a SATA controller to an IDE controller. Then again,
it can be done using VBoxManage:

    vboxmanage storagectl <UUID> --name "SATA Controller" --remove
    vboxmanage storageattach <UUID> --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium /path/to/box-disk1.vmdk

Vagrant provides a way to customize a VM thanks to the `config.vm.customize`
parameter:

    config.vm.customize ["modifyvm", :id, "--memory", 1024]

However, we decided to patch the boxes instead of using this parameter. One
reason was that we didn't know how to get the path to the `vmdk` file.

We were able to boot a `lucid32` VM but a new issue appeared: NFS. In order to
share the current working directory with the VM, we used this configuration in
the `Vagrantfile`:

    config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)

It worked fine without NFS set to `true` but it was quite slow. Thus, NFS was a
requirement.

## The surprise

I dug into the code to understand how NFS was managed and why it was asking
for admin credentials. I was really suprised while reading the code. There was
no way to configure Vagrant to control the NFS part and, sadly, it was asking
the `root` password because of a call to `sudo su root`.

There is no way to give the `root` password to our users (mainly students). We
ended up patching Vagrant to use `exportfs` and a shell script to perform `sed`.
`nfsd` is always up so there is no need to restart it and `exportfs` does a
decent job. Since `/etc` is not writable for everyone, we used a shell script
to change the content of `/etc/exports` using a simple `sed -i -e`. Now, both
commands are sudoable.

And, that's it! Our users can use Vagrant as usual.

## Useful tips

Debugging Vagrant can be really useful, especially when you start playing with
VM customization. To enable logging, use the `VAGRANT_LOG` environment variable:

    VAGRANT_LOG=INFO vagrant up

Hardware virtualization **should** be enabled if you want to run 64-bit VMs on
a 32-bit host. The VirtualBox documentation isn't super clear about that in the
chapter about [hardware vs software virtualization][hwvirt].

## Conclusion

Vagrant needs some improvements to be more easily configurable and a bit safer
in my opinion. However, workarounds exist. In the end, Vagrant is a great tool
and it just works!

[hwvirt]: https://www.virtualbox.org/manual/ch10.html#hwvirt
[official box]: https://www.vagrantup.com/docs/boxes
[rmmod]: https://man7.org/linux/man-pages/man8/rmmod.8.html
[setproperty]: https://www.virtualbox.org/manual/ch08.html#vboxmanage-setproperty
[Vagrant]: https://www.vagrantup.com/
[VirtualBox]: https://wiki.debian.org/VirtualBox