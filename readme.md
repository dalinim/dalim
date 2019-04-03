# Dalim - DEX nim backend 

This repository contains work in progress of a nim compiler with a dex backend. 

DEX is the assembly language used by the dalvik virtual machine. In android system it is used to represent the bytecode produced by java compilers. 

**This is not the offical nim github page**
For the *real* nim-lang, please use link below 

[NIM-lang](https://github.com/nim-lang/Nim/)
 
The DEX assembler that is being targeted.  
[Dali](https://github.com/akavel/dali)

## Plan
The aims are currently humble, and consist of firstly compiling simple programs. 

## Compiling

Compiling the Nim compiler is quite straightforward if you follow these steps:

First, the C source of an older version of the Nim compiler is needed to
bootstrap the latest version because the Nim compiler itself is written in the
Nim programming language. Those C sources are available within the 
[``nim-lang/csources``][csources-repo] repository.

Next, to build from source you will need:

  * A C compiler such as ``gcc`` 3.x/later or an alternative such as ``clang``,
    ``Visual C++`` or ``Intel C++``. It is recommended to use ``gcc`` 3.x or
    later.
  * Either ``git`` or ``wget`` to download the needed source repositories.
  * The ``build-essential`` package when using ``gcc`` on Ubuntu (and likely
    other distros as well). 

Then, if you are on a \*nix system or Windows, the following steps should compile
Nim from source using ``gcc``, ``git`` and the ``koch`` build tool.

**Note: The following commands are for the development version of the compiler.**
For most users, installing the latest stable version is enough. Check out
the installation instructions on the website to do so: https://nim-lang.org/install.html.

For package mantainers: see [packaging guidelines](https://nim-lang.github.io/Nim/packaging.html).

```
# step 1:
git clone https://github.com/nim-lang/Nim.git
cd Nim

# step 2 (posix) clones `csources.git`, bootstraps Nim compiler and compiles tools
sh build_all.sh

# step 2 (windows)
git clone --depth 1 https://github.com/nim-lang/csources.git

cd csources
# requires `gcc` in your PATH, see also https://nim-lang.org/install_windows.html
build.bat # x86 Windows
build64.bat # x86_64 Windows
cd ..

bin\nim c koch
koch boot -d:release
koch tools # Compile Nimble and other tools
# end of step 2 (windows)
```

Finally, once you have finished the build steps (on Windows, Mac or Linux) you
should add the ``bin`` directory to your PATH.

## Koch

``koch`` is the build tool used to build various parts of Nim and to generate
documentation and the website, among other things. The ``koch`` tool can also
be used to run the Nim test suite. 

Assuming that you added Nim's ``bin`` directory to your PATH, you may execute
the tests using ``./koch tests``. The tests take a while to run, but you
can run a subset of tests by specifying a category (for example 
``./koch tests cat async``).

For more information on the ``koch`` build tool please see the documentation
within the [doc/koch.rst](doc/koch.rst) file.

## Nimble

``nimble`` is Nim's package manager. To learn more about it, see the
[``nim-lang/nimble``][nimble-repo] repository.

## Usage 

Bear in mind that this is work in progress, but the usage will be something along these lines. 

``bin/nim dex fib.nim`` 

Currently prints out a subset of the AST. More to come shortly!

## License
The compiler and the standard library are licensed under the MIT license, except
for some modules which explicitly state otherwise. As a result you may use any
compatible license (essentially any license) for your own programs developed with
Nim. You are explicitly permitted to develop commercial applications using Nim.

Please read the [copying.txt](copying.txt) file for more details.

Copyright © 2006-2019 Andreas Rumpf, all rights reserved.
