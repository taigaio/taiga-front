## Taiga Front

[![Managed with Taiga.io](https://img.shields.io/badge/managed%20with-TAIGA.io-709f14.svg)](https://tree.taiga.io/project/taiga/ "Managed with Taiga.io")
[![Build Status](https://img.shields.io/travis/taigaio/taiga-front.svg)](https://travis-ci.org/taigaio/taiga-front "Build Status")

## Get the compiled version

You can get the compiled version of this code in the
[taiga-front-dist](http://github.com/taigaio/taiga-front-dist) repository

## Documentation

Currently, we have authored three main documentation hubs:

-   **[API](https://docs.taiga.io/api.html)**: Our API documentation and reference for developing from Taiga API.
-   **[Documentation](https://docs.taiga.io/)**: If you need to install Taiga on your own server, this is the place to find some guides.
-   **[Taiga Community](https://community.taiga.io/)**: This page is intended to be the support reference page for the users.

## Bug reports

If you **find a bug** in Taiga you can always report it:

-   in [Taiga issues](https://tree.taiga.io/project/taiga/issues). **This is the preferred way**
-   in [Github issues](https://github.com/taigaio/taiga-front/issues)
-   send us a mail to support@taiga.io if is a bug related to [tree.taiga.io](https://tree.taiga.io)
-   send us a mail to security@taiga.io if is a **security bug**.

One of our fellow Taiga developers will search, find and hunt it as soon as possible.

Please, before reporting a bug, write down how can we reproduce it, your operating system, your browser and version, and if it's possible, a screenshot. Sometimes it takes less time to fix a bug if the developer knows how to find it.

## Community

If you **need help to setup Taiga**, want to **talk about some cool enhancement** or you have **some questions**, please go to [Taiga community](https://community.taiga.io/).

If you want to be up to date about announcements of releases, important changes and so on, you can subscribe to our newsletter (you will find it by scrolling down at [https://taiga.io](https://www.taiga.io/)) and follow [@taigaio](https://twitter.com/taigaio) on Twitter.

## Contribute to Taiga

There are many different ways to contribute to Taiga's platform, from patches, to documentation and UI enhancements, just find the one that best fits with your skills. Check out our detailed [contribution guide](https://community.taiga.io/t/how-can-i-contribute/159)

## Code of Conduct

Help us keep the Taiga Community open and inclusive. Please read and follow our [Code of Conduct](https://github.com/taigaio/code-of-conduct/blob/main/CODE_OF_CONDUCT.md).

## License

Every code patch accepted in this repository is licensed under [AGPL 3.0](LICENSE). You must be careful to not include any code that can not be licensed under this license.

Please read carefully [our license](LICENSE) and ask us if you have any questions as well as the [Contribution policy](https://github.com/taigaio/taiga-front/blob/main/CONTRIBUTING.md).

## Initial dev env

Install requirements:

**Node + Gulp**

We recommend using [nvm](https://github.com/creationix/nvm) to manage different node versions

```
npm start
```

And go in your browser to: http://localhost:9001/

#### E2E test

If you want to run e2e tests

```
npm install -g protractor
npm install -g mocha
npm install -g babel@5

webdriver-manager update
```

To run a local Selenium Server, you will need to have the Java Development Kit (JDK) installed.

## Tests

#### Unit tests

-   To run **unit tests**

    ```
    npx gulp
    ```

    ```
    npm test
    ```

#### E2E tests

-   To run **e2e tests** you need [taiga-back](https://github.com/taigaio/taiga-back) running and

    ```
    npx gulp
    ```

    ```
    webdriver-manager start
    ```

    ```
    protractor conf.e2e.js --suite=auth     # To tests authentication
    protractor conf.e2e.js --suite=full     # To test all the platform authenticated
    ```
