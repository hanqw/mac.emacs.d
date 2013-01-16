<<<<<<< HEAD
# Steve Purcell's original README
This is an emacs configuration tree that supports a number of
programming languages, particularly Ruby/Rails and other dynamic
languages including Clojure, PHP, Python etc.

In particular, I have a nice config for tab autocompletion, and
flymake is used to immediately highlight syntax errors in Ruby, HAML,
Python, Javascript, PHP and some other languages.

To install, clone this repo to ~/.emacs.d, i.e. ensure that the
'init.el' contained in this repo ends up at ~/.emacs.d/init.el.
Before starting up Emacs, be sure to run 'git submodule update --init'
to pull in the dependencies that have git repos. Upon starting up Emacs
for the first time, further third-party packages will be automatically
downloaded and installed, which may require 'svn' to be on your PATH.

Although these config files aren't meant to be a replacement for
emacs-starter-kit, some of the tips & tricks contained herein might be
useful to others, and there are flags at the top of init.el which can
toggle certain features that might annoy people who aren't me,
e.g. the "viper" vi emulation.

I use Emacs HEAD on a Mac, but the config should work in other
environments too, with any Emacs version >= 23. If not, please file an
issue on the github project: https://github.com/purcell/emacs.d

-Steve Purcell

# Chen Bin's README

I base my configuration on Purcell's and sync from his frequently.

## My additions

* 'git submodule update --init' is NOT needed. I removed all the 'git submodule' stuff.
* some major/minor modes for C/C++ developers
* emacs-w3m (console browser)
* eim (Chinese pinyin input method)
* org2blog (write wordpress blog with org-mode)
* make the configuration work under Linux and Cygwin
* The configuration will work with Emacs version >=23.4
* remove the dependency on subversion (svn)

## Third party CLI tools Emacs uses

Purcell won't list all the 3rd party tools this configuration dependent on. I will
try to list them HERE,

* w3m (web browser in console)
* jsl (jslint)
* aspell, and some dictionary like aspell-en
* tidy
* zip and unzip
  export org to odt
* clang
  auto-complete/intellisense by using clang (http://clang.llvm.org)
* ctags (http://ctags.sourceforge.net)
  You use ctags to navigate the code.
* GNU Global (http://www.gnu.org/software/global)
  You use this tool to navigate the code.
* pyflakes
  install pip, then `pip install pyflakes`, but on cygwin you need install
  setuptool in order to install pip.
* ditaa, grapviz and planetuml to convert ascii art to diagram and uml.

To install the tools, I suggest using,
* apt-cyg at Cygwin
* homebrew at OS X
* any package manager at Linux

Please note it's totally fine you don't install these CLI tools. Emacs won't crash. ;)
## Report bug
If you find any bug, please file an issue on the github project:
https://github.com/redguardtoo/emacs.d

## Warnings
* by default EVIL (Vim emulation in Emacs) is used. You can comment out
 line containing "(require 'init-evil)" in init.el to unload it.
* Some package cannot be downloaded automatically because of network problem.
You need manually `M-x list-packages` and install it.
* I downgraded the yasnippet to an older version because latest yasnippet is
not compatible with auto-complete.

## My personal Emacs configuration (custom.el)
It's publicized at http://blog.binchen.org/?p=430 .
=======
Dotemacs
========

emacs profile ,private ,by han quanwei
>>>>>>> ecf23ea7539220b2462e244930fe01e93d82f923
