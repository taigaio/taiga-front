# Taiga e2e tests #

### Setup ###

```
npm install
npm install -g protractor
npm install -g mocha
npm install -g babel

webdriver-manager update
```

### Usage ###

After taiga-back and taiga-front are running

```
webdriver-manager start
```

run test:

```
protractor conf.e2e.js --suite=suiteName
```
