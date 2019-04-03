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

The compiler currently officially supports the following platform and
architecture combinations:

  * Windows (Windows XP or greater) - x86 and x86_64
  * Linux (most, if not all, distributions) - x86, x86_64, ppc64 and armv6l
  * Mac OS X (10.04 or greater) - x86, x86_64 and ppc64

More platforms are supported, however they are not tested regularly and they
may not be as stable as the above-listed platforms.

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

## Contributors

This project exists thanks to all the people who contribute.
<a href="https://github.com/nim-lang/Nim/graphs/contributors"><img src="https://opencollective.com/Nim/contributors.svg?width=890" /></a>

## Contributing

[![Backers on Open Collective](https://opencollective.com/nim/backers/badge.svg)](#backers) [![Sponsors on Open Collective](https://opencollective.com/nim/sponsors/badge.svg)](#sponsors)
[![Setup a bounty via Bountysource][badge-nim-bountysource]][nim-bountysource]
[![Donate Bitcoins][badge-nim-bitcoin]][nim-bitcoin]
[![Open Source Helpers](https://www.codetriage.com/nim-lang/nim/badges/users.svg)](https://www.codetriage.com/nim-lang/nim)

See [detailed contributing guidelines](https://nim-lang.github.io/Nim/contributing.html).
We welcome all contributions to Nim regardless of how small or large
they are. Everything from spelling fixes to new modules to be included in the
standard library are welcomed and appreciated. Before you start contributing,
you should familiarize yourself with the following repository structure:

* ``bin/``, ``build/`` - these directories are empty, but are used when Nim is built.
* ``compiler/`` - the compiler source code. Also includes nimfix, and plugins within
  ``compiler/nimfix`` and ``compiler/plugins`` respectively.
* ``nimsuggest`` - the nimsuggest tool that previously lived in the [``nim-lang/nimsuggest``][nimsuggest-repo] repository. 
* ``config/`` - the configuration for the compiler and documentation generator.
* ``doc/`` - the documentation files in reStructuredText format.
* ``lib/`` - the standard library, including:
    * ``pure/`` - modules in the standard library written in pure Nim.
    * ``impure/`` - modules in the standard library written in pure Nim with
    dependencies written in other languages.
    * ``wrappers/`` - modules which wrap dependencies written in other languages.
* ``tests/`` - contains categorized tests for the compiler and standard library.
* ``tools/`` - the tools including ``niminst`` and ``nimweb`` (mostly invoked via
  ``koch``).
* ``koch.nim`` - tool used to bootstrap Nim, generate C sources, build the website,
  and generate the documentation.

If you are not familiar with making a pull request using GitHub and/or git, please
read [this guide][pull-request-instructions].


## License
The compiler and the standard library are licensed under the MIT license, except
for some modules which explicitly state otherwise. As a result you may use any
compatible license (essentially any license) for your own programs developed with
Nim. You are explicitly permitted to develop commercial applications using Nim.

Please read the [copying.txt](copying.txt) file for more details.

Copyright © 2006-2019 Andreas Rumpf, all rights reserved.
