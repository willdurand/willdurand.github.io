---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: true
tags: [ PHP ]
title: "Enforcing Data Encapsulation with Symfony Forms"
---

**Encapsulation** is **one of the four fundamentals** in Object-Oriented
Programming (OOP). It is used [to hide the values or state of a structured
object inside a
class](http://en.wikipedia.org/wiki/Encapsulation_\(object-oriented_programming\)),
preventing unauthorized parties direct access to them. That is why you should
[avoid getters and
setters](http://williamdurand.fr/2013/06/03/object-calisthenics/#9-no-getters/setters/properties)
as much as you can, not to say all the time!

However, using the [Symfony
Form](http://symfony.com/doc/current/components/form/introduction.html)
component, you may think that it is not possible. Guess what? It is actually
possible, and it is really easy thanks to the
[`empty_data`](http://symfony.com/doc/current/cookbook/form/use_empty_data.html#option-2-provide-a-closure)
option!

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

The `Email` value object can be defined as follow. Thank you
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

In your `CustomerType`, all you need to do is configuring the `empty_data`
option in the `setDefaultOptions()` method using a **closure**:

```php
<?php

namespace My\Form\Type;

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
        );
    }

    /**
     * {@inheritdoc}
     */
    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
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

No more excuse to write crappy code now!

PS: Mathias Verraes describes another approach in [Decoupling (Symfony2) Forms
from
Entities](http://verraes.net/2013/04/decoupling-symfony2-forms-from-entities/).
