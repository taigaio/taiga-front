# Taiga Front #

[![Kaleidos Project](http://kaleidos.net/static/img/badge.png)](https://github.com/kaleidos "Kaleidos Project")
[![Managed with Taiga.io](https://img.shields.io/badge/managed%20with-TAIGA.io-709f14.svg)](https://tree.taiga.io/project/taiga/ "Managed with Taiga.io")
[![Build Status](https://img.shields.io/travis/taigaio/taiga-front.svg)](https://travis-ci.org/taigaio/taiga-front "Build Status")

## Get the compiled version ##

You can get the compiled version of this code in the
[taiga-front-dist](http://github.com/taigaio/taiga-front-dist) repository


## Contribute to Taiga ##

#### Where to start ####

There are many different ways to contribute to Taiga's development, just find the one that best fits with your skills. Examples of contributions we would love to receive include:

- **Code patches**
- **Documentation improvements**
- **Translations**
- **Bug reports**
- **Patch reviews**
- **UI enhancements**

Big features are also welcome but if you want to see your contributions included in Taiga codebase we strongly recommend you start by initiating a chat though our [mailing list](http://groups.google.co.uk/d/forum/taigaio)


#### Code of Conduct ####

Help us keep the Taiga Community open and inclusive. Please read and follow our [Code of Conduct](https://github.com/taigaio/code-of-conduct/blob/master/CODE_OF_CONDUCT.md).


#### License ####

Every code patch accepted in taiga codebase is licensed under [AGPL v3.0](http://www.gnu.org/licenses/agpl-3.0.html). You must be careful to not include any code that can not be licensed under this license.

Please read carefully [our license](https://github.com/taigaio/taiga-front/blob/master/LICENSE) and ask us if you have any questions.

Emoji provided free by [Twemoji](https://github.com/twitter/twemoji)

#### Bug reports, enhancements and support ####

If you **need help to setup Taiga**, want to **talk about some cool enhancement** or you have **some questions**, please write us to our [mailing list](http://groups.google.com/d/forum/taigaio).

If you **find a bug** in Taiga you can always report it:

- in our [mailing list](http://groups.google.com/d/forum/taigaio).
- in [github issues](https://github.com/taigaio/taiga-front/issues).
- send us a mail to support@taiga.io if is a bug related to [tree.taiga.io](https://tree.taiga.io).
- send a mail to security@taiga.io if is a **security bug**.

One of our fellow Taiga developers will search, find and hunt it as soon as possible.

Please, before reporting a bug write down how can we reproduce it, your operating system, your browser and version, and if it's possible, a screenshot. Sometimes it takes less time to fix a bug if the developer knows how to find it and we will solve your problem as fast as possible.


#### Documentation improvements ####

We are gathering lots of information from our users to build and enhance our documentation. If you use the documentation to install or develop with Taiga and find any mistakes, omissions or confused sequences, it is enormously helpful to report it. Or better still, if you believe you can author additions, please make a pull-request to taiga project.

Currently, we have authored three main documentation hubs:

- **[API Docs](https://github.com/taigaio/taiga-doc)**: Our API documentation and reference for developing from Taiga API.
- **[Installation Guide](https://github.com/taigaio/taiga-doc)**: If you need to install Taiga on your own server, this is the place to find some guides.
- **[Taiga Support](https://github.com/taigaio/taiga-doc)**: This page is intended to be the support reference page for the users. If you find any mistake, please report it.


#### Translation ####

We are ready now to accept your help translating Taiga. It's easy (and fun!) just access our team of translators with the link below, set up an account in Transifex and start contributing. Join us to make sure your language is covered! **[Help Taiga to translate content](https://www.transifex.com/signup/ "Help Taiga to translate content")**


#### Code patches ####

Taiga will always be glad to receive code patches to update, fix or improve its code.

If you know how to improve our code base or you found a bug, a security vulnerability or a performance issue and you think you can solve it, we will be very happy to accept your pull-request. If your code requires considerable changes, we recommend you first  talk to us directly. We will find the best way to help.


#### UI enhancements ####

Taiga is made for developers and designers. We care enormously about UI because usability and design are both critical aspects of the Taiga experience.

There are two possible ways to contribute to our UI:
- **Bugs**: If you find a bug regarding front-end, please report it as previously indicated in the Bug reports section or send a pull-request as indicated in the Code Patches section.
- **Enhancements**: If its a design or UX bug or enhancement we will love to receive your feedback. Please send us your enhancement, with the reason and, if possible, an example. Our design and UX team will review your enhancement and fix it as soon as possible. We recommend you to use our [mailing list](http://groups.google.co.uk/d/forum/taigaio) so we can have a lot of different opinions and debate.
- **Language Localization**: We are eager to offer localized versions of Taiga. Some members of the community have already volunteered to work to provide a variety of languages. We are working to implement some changes to allow for this and expect to accept these requests in the near future.



## Community ##

[Taiga has a mailing list](http://groups.google.com/d/forum/taigaio). Feel free to join it and ask any questions you may have.

To subscribe for announcements of releases, important changes and so on, please follow [@taigaio](https://twitter.com/taigaio) on Twitter.


## Donations ##

We are grateful for your emails volunteering donations to Taiga. We feel comfortable accepting them under these conditions: The first that we will only do so while we are in the current beta / pre-revenue stage and that whatever money is donated will go towards a bounty fund. Starting Q2 2015 we will be engaging much more actively with our community to help further the development of Taiga, and we will use these donations to reward people working alongside us.

If you wish to make a donation to this Taiga fund, you can do so via http://www.paypal.com using the email: eposner@taiga.io


## Setup ##

All the information about the different installation methods (production, development, vagrant, docker...) can be found here http://taigaio.github.io/taiga-doc/dist/#_installation_guide.

#### Initial dev env ####

Install requirements:

**Ruby / Sass**

You can install Ruby through the apt package manager, rbenv, or rvm.
Install Sass through your **Terminal or Command Prompt**.

```
gem install sass scss-lint
export PATH="~/.gem/ruby/2.1.0/bin:$PATH"
sass -v             # should return Sass 3.3.8 (Maptastic Maple)
```

Complete process for all OS at: http://sass-lang.com/install

**Node + Gulp**

We recommend using [nvm](https://github.com/creationix/nvm) to manage different node versions
```
npm install -g gulp
npm install
gulp
```

And go in your browser to: http://localhost:9001/

#### E2E test ####

If you want to run e2e tests

```
npm install -g protractor
npm install -g mocha
npm install -g babel@5

webdriver-manager update
```

To run a local Selenium Server, you will need to have the Java Development Kit (JDK) installed.

## Tests ##

#### Unit tests ####

- To run **unit tests**

  ```
  gulp
  ```
  ```
  npm test
  ```

#### E2E tests ####

- To run **e2e tests** you need [taiga-back](https://github.com/taigaio/taiga-back) running and

  ```
  gulp
  ```
  ```
  webdriver-manager start
  ```
  ```
  protractor conf.e2e.js --suite=auth     # To tests authentication
  protractor conf.e2e.js --suite=full     # To test all the platform authenticated
  ```
