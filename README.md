# Taiga Front #

![Kaleidos Project](http://kaleidos.net/static/img/badge.png "Kaleidos Project")

## Setup initial environment ##

Install requirements:

**Ruby / Sass**

You can install Ruby through the apt package manager, rbenv, or rvm.
Install Sass through your **Terminal or Command Prompt**.

```
$ gem install sass scss-lint
$ export PATH="~/.gem/ruby/2.1.0/bin:$PATH"
$ sass -v // should return Sass 3.3.8 (Maptastic Maple)
```

Complete process for all OS at: http://sass-lang.com/install

**Node + Bower + Gulp**

```
$ sudo npm install -g gulp
$ sudo npm install -g bower
$ npm install
$ bower install
$ gulp
```

And go in your browser to: http://localhost:9001/

All the information about the different installation methods (production, development, vagrant, docker...) can be found here http://taigaio.github.io/taiga-doc/dist/#_installation_guide. 

## Community ##

[Taiga has a mailing list](http://groups.google.com/d/forum/taigaio). Feel free to join it and ask any questions you may have.

To subscribe for announcements of releases, important changes and so on, please follow [@taigaio](https://twitter.com/taigaio) on Twitter.
