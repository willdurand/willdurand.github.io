---
layout: post
title: "Unit testing C code with LD_PRELOAD"
audio: true
tldr: false
location: "Freiburg, Germany"
image:
tweet_id:
---

One of my side projects is [a tiny kernel/operating
system](https://github.com/willdurand/willOS), which I started to learn more
about operating systems (OS) and kernel development in general. The codebase is
fairly small (around 4K lines of code at the time of writing) but I started to
face a few bugs that I could have likely avoided with unit testing.

Writing a kernel often implies creating a lot of things from scratch, even the
most basic "tools". For example, some sort of small [C
library](https://wiki.osdev.org/C_Library) is required early in the process.
Yet, it is hard to port an existing _libc_ when there is nothing else. Such a C
library does not have tons of functions but everything else will depend on them.
Therefore, it is crucial to write them correctly and unit testing can help.

In my project, I chose to have a unified C library for both my kernel code
(which uses a library sometimes called _libk_) and
[userland](https://en.wikipedia.org/wiki/User_space) code (which uses a _libc_
like [glibc](https://www.gnu.org/software/libc/)). Because my C library provides
the same API as other _libc_ (_.e.g._ the one from my system), I could not
directly import my functions in my test code. I thought about this problem and
came up with three options:

1. Introduce a `PREFIX()` macro to alias my functions and import these aliased
   functions in the test code. This is needed because "global function" names
   should be unique in C. This option would improve isolation but it would make
   the kernel code harder to read.
2. Use my C library to write test programs. This option would make debugging
   harder as not even the test code could be "trusted". I would prefer not to
   rely on my incomplete _libc_ too much.
3. Override the function under test (_FUT_) when running the test program. It is
   a combination of (1) and (2) and this guarantees that only the FUT is tested.

This idea of [monkey-patching](https://en.wikipedia.org/wiki/Monkey_patch) code
did ring a bell: the [`LD_PRELOAD` environment
variable](https://blog.jessfraz.com/post/ld_preload/)! In order to understand
how this works, let's remember that programs can be either statically or
dynamically linked. The former creates programs that contain a "copy" of the
functions borrowed from external libraries while the latter binds such functions
upon program execution.

`LD_PRELOAD` can be used to load a shared library before other libraries,
offering us the ability to change the behaviors of the functions used by a
program 🔥

## Example

Let's take an example with an enhanced version of a "Hello, World" written in C
(the reason why this source code is more complicated than it should is covered
at the end of this article):

```c
// hello.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  const char* hello = "hello!";
  char* name = malloc(7 * sizeof(char));
  strcpy(name, hello);

  printf("%s\n", name);

  free(name);

  return 0;
}
```

The example above uses `strcpy()` to copy a string that will be printed to the
standard output as shown below (I used `gcc -o hello hello.c` to compile this
program):

```
$ ./hello
hello!
```

As mentioned previously, we could leverage `LD_PRELOAD` to override the behavior
of the `strcpy()` function. In order to do this, we need to create a new file
(`evil.c`) with the following content:

```c
// evil.c

char* strcpy(char* dest, const char* src) {
  const char* evil = "oooops";

  while (*evil) {
    *dest++ = *evil++;
  }
  *dest = '\0';

  return dest;
}
```

Instead of using the content from the second argument, this function copies its
own string 😈 `LD_PRELOAD` needs a shared library so we have to compile this
file with `gcc -fPIC -shared -o evil.so evil.c`. `PIC` stands for _Position
Independent Code_, which means that the generated code is not dependent on being
located at a specific address in order to work. The `-shared` option instructs
the linker to create a shared object (`.so`), which is our final library. Let's
try it now:

```
$ LD_PRELOAD=./evil.so ./hello
oooops
```

## Heh, what happened?

This worked because the `hello` program did not embed `strcpy()`. We can verify
it with `objdump` (with the `-t` flag to print the symbol table entries of the
file):

```
$ objdump -t hello

hello:     file format elf64-x86-64

SYMBOL TABLE:
...
0000000000000000       F *UND*	0000000000000000              strcpy@@GLIBC_2.2.5
...
000000000000071a g     F .text	0000000000000053              main
...
```

Although it is technically not correct, let's pretend that a function and a
symbol are the same. The partial output above shows the table entry for the
`strcpy` function. The first column represents its _address_ and
`0000000000000000` (as well as `*UND*`) means the function is not defined in
this binary file. This table also lists our `main` function, which can be
found at address `000000000000071a` (_i.e._ somewhere inside the binary file).

Now, let's explore our shared library with the same command:

```
$ objdump -t evil.so

evil.so:     file format elf64-x86-64

SYMBOL TABLE:
...
000000000000057a g     F .text	000000000000004e strcpy
...
```

Our library provides a `strcpy` function at address `000000000000004e`. When we
run the `hello` program, the operating system binds the symbols to their actual
definitions located in shared libraries. The `ldd` tool can tell us which shared
libraries are used when we want to execute our program:

```
$ ldd ./hello
    linux-vdso.so.1 (0x00007fff775c3000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fd4ae478000)
    /lib64/ld-linux-x86-64.so.2 (0x00007fd4aea6b000)
```

We used `LD_PRELOAD` to tell the operating system (and its dynamic linker) to
use our shared library (almost) first, which is why our program ended up calling
our version of `strcpy`:

```
$ LD_PRELOAD=./evil.so ldd ./hello
    linux-vdso.so.1 (0x00007fffa0759000)
    ./evil.so (0x00007ff46f155000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007ff46ed64000)
    /lib64/ld-linux-x86-64.so.2 (0x00007ff46f559000)
```

That's what happened!

## Compilers are (too) smart.

I used a similar approach to write tests for my little kernel
([patch](https://github.com/willdurand/willOS/pull/21)) but it did not always
work well. For example, I could not test the `strlen()` function because the
compiler optimized my code in a way that there was no need to link to the
`strlen()` function anymore. In other words, the symbol table did not contain
any reference to `strlen`.

We can update our `hello.c` file to reproduce the problem. For example, let's
add a `strlen()` call to output the number `4`:

```diff
diff --git a/hello.c b/hello.c
index a9744a9..f2b139d 100644
--- a/hello.c
+++ b/hello.c
@@ -7,7 +7,7 @@ int main() {
   char* name = malloc(7 * sizeof(char));
   strcpy(name, hello);

-  printf("%s\n", name);
+  printf("%s %ld\n", name, strlen("four"));

   free(name);
```

As expected, inspecting the symbol table of the recompiled `hello` program will
lead to no reference to the `strlen()` function, which is why I did not provide
any output here. Instead, we can confirm that the compiler optimized our code by
disassembling the program with `objdump -d`:

```
$ objdump -d -Mintel hello

hello:     file format elf64-x86-64

...
 749:	e8 82 fe ff ff       	call   5d0 <strcpy@plt>
 74e:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
 752:	ba 04 00 00 00       	mov    edx,0x4
 757:	48 89 c6             	mov    rsi,rax
 75a:	48 8d 3d aa 00 00 00 	lea    rdi,[rip+0xaa]        # 80b <_IO_stdin_used+0xb>
 761:	b8 00 00 00 00       	mov    eax,0x0
 766:	e8 75 fe ff ff       	call   5e0 <printf@plt>
...
```

There is no `call` to `strlen` but the value `4` (`0x4`) is moved to a register
before calling `printf`. The compiler optimized our code!

## Conclusion

I leveraged the `LD_PRELOAD` environment variable to inject a function under
test in a test program. The test program is linked against whatever _libc_ is
installed on the system and only the FUT is replaced. That way, the test code
can be trusted and we can compare the behavior of the FUT with the equivalent
function in the system's _libc_.

While it is an efficient method to write simple unit tests, it still requires
some extra checks to make sure we are not testing the numerous compiler
optimizations that would completely skip the FUT.

With these _libc_ functions implemented and tested, I could build new features
on top of them with confidence and write "traditional" unit tests for these
modules.
