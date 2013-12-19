---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: true
tags: [ PHP ]
title: "Enforcing Data Encapsulation with Symfony Forms"
---

**Update:** [Mathias and I exchanged a few
tweets](https://twitter.com/couac/status/412677521977921536), so I updated this
post a bit to give the context.

---


Having classes (entities or whatever related to your model layer) that exposes
attributes publicly, i.e. setters and getters for all attributes is just a **non
sense**. Basically, a class with _attributes/getters/setters_ is the same thing
as a class with public properties or even as an array. **Don't do that!**

You should rather write classes that own data, and keep them in a safe place.
That is called **encapsulation**. **Encapsulation** is **one of the four
fundamentals** in Object-Oriented Programming (OOP). It is used [to hide the
values or state of a structured object inside a
class](http://en.wikipedia.org/wiki/Encapsulation_\(object-oriented_programming\)),
preventing unauthorized parties direct access to them. That is why you should
[avoid getters and
setters](http://williamdurand.fr/2013/06/03/object-calisthenics/#9-no-getters/setters/properties)
as much as you can, not to say all the time!

Working with the [Symfony
Form](http://symfony.com/doc/current/components/form/introduction.html), it may
be hard to decouple your code, and to not rely on getters and setters. Mathias
Verraes describes a great approach in [Decoupling (Symfony2) Forms from
Entities](http://verraes.net/2013/04/decoupling-symfony2-forms-from-entities/),
and I strongly agree with him. To sum up, the Form component should be used in
your Presentation Layer, and it should not mess with your Model Layer. Use
commands or DTOs with Forms, then create or act on your Model entities in the
Application Layer (i.e. in your controllers).

However, the aim of this blog post is to show you how to keep **decent model
classes** even with the Form component. In other words, don't write poor model
classes because of the framework you are using. You should design your model
classes to fit your business, and according to OOP paradigms, not because
framework X sucks at hydrating an object. I guess it is Hibernate's fault at
some point, at least in the Java world with their
[POJOs/JavaBeans](http://en.wikipedia.org/wiki/Plain_Old_Java_Object), but I am
digressing...

The solution to not rely on getters and setters is to control how objects are
created into the Form component. In order to do that, you can rely on the
[`empty_data`](http://symfony.com/doc/current/cookbook/form/use_empty_data.html#option-2-provide-a-closure)
option.

Let's take an example. Among other things, your model layer defines a `Customer`
entity that owns a `name` and an `Email` value object. You don't want to break
encapsulation and [write SOLID
code](http://williamdurand.fr/2013/07/30/from-stupid-to-solid-code/) instead, so
you end up writing the following `Customer` class definition:

```php
<?php

namespace My\Model;

class Customer
{
    private $name;

    /**
     * @var Email
     */
    private $email;

    public function __construct($name, Email $email)
    {
        $this->name  = $name;
        $this->email = $email;
    }
}
```

The `Email` value object can be defined as follows. Thank you
[Mathias](http://verraes.net/) by the way.

```php
<?php

namespace My\Model;

class Email
{
    private $email;

    public function __construct($email)
    {
        $this->email = $email;
    }
}
```

In your `CustomerType`, all you need to do is configure the `empty_data`
option in the `setDefaultOptions()` method using a **closure**:

```php
<?php

namespace My\Form\Type;

use My\Model\Customer;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\FormInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;

class CustomerType extends AbstractType
{
    /**
     * {@inheritdoc}
     */
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('name', 'string')
            ->add('email', new EmailType())
        ;
    }

    /**
     * {@inheritdoc}
     */
    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => 'My\Model\Customer',
            'empty_data' => function (FormInterface $form) {
                return new Customer(
                    $form->get('name')->getData(),
                    $form->get('email')->getData()
                );
            }
        ));
    }

    // ...
}
```

It is worth mentioning that it works fine with custom types, collections, and so
on. In the example above, it relies on a custom `EmailType` rather than directly
using the built-in `email` type and creating the value object in the
`CustomerType`. The creation is left to this `EmailType`. Calling `getData()` on
`$form->get('email')` actually returns an `Email` object.

For the record, here is the `EmailType` definition:

```php
<?php

namespace My\Form\Type;

use My\Model\Email;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\FormInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;

class EmailType extends AbstractType
{
    /**
     * {@inheritdoc}
     */
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('email', 'email');
    }

    /**
     * {@inheritdoc}
     */
    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => 'My\Model\Email',
            'empty_data' => function (FormInterface $form) {
                return new Email(
                    $form->get('email')->getData()
                );
            }
        ));
    }

    // ...
}
```

No more excuse to write crappy model classes now!
