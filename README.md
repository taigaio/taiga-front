# Taiga Front #

![Kaleidos Project](http://kaleidos.net/static/img/badge.png "Kaleidos Project")
[![Managed with Taiga](https://taiga.io/media/support/attachments/article-22/banner-gh.png)](https://taiga.io "Managed with Taiga")
[![Build Status](https://travis-ci.org/taigaio/taiga-front.svg?branch=public-header-bar)](https://travis-ci.org/taigaio/taiga-front)

## Get the compiled version ##

You can get the compiled version of this code in the
[taiga-front-dist](http://github.com/taigaio/taiga-front-dist) repository

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

## Donations ##

We are grateful for your emails volunteering donations to Taiga. We feel comfortable accepting them under these conditions: The first that we will only do so while we are in the current beta / pre-revenue stage and that whatever money is donated will go towards a bounty fund. Starting Q2 2015 we will be engaging much more actively with our community to help further the development of Taiga, and we will use these donations to reward people working alongside us.

If you wish to make a donation to this Taiga fund, you can do so via http://www.paypal.com using the email: eposner@taiga.io

