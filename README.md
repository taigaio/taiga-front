# تایگا فارسی | Taiga Front Persian (تم سیاپیچا) 🇮🇷

### سامانه مدیریت پروژه متن‌باز و چابک (اسکرام و کانبان) بهینه‌شده برای فارسی

**Persian Open Source Agile Project Management (Scrum & Kanban) — Taiga Front RTL Edition**

[![Managed with Taiga.io](https://img.shields.io/badge/managed%20with-TAIGA.io-709f14.svg)](https://tree.taiga.io/project/taiga/ "Managed with Taiga.io")
[![Taiga Persian](https://img.shields.io/badge/Taiga-Persian-4F46E5.svg)](#)
[![Font](https://img.shields.io/badge/Font-Vazirmatn-10B981.svg)](#)
[![RTL](https://img.shields.io/badge/RTL-Optimized-blue.svg)](#)

نسخه بومی و بهینه‌سازی‌شده **Taiga Front** برای تیم‌های فارسی‌زبان؛ مجهز به فونت وزیرمتن، چیدمان کاملاً راست‌چین (RTL)، تم مدرن **سیاپیچا (Siapicha)** و ترجمه کامل فارسی برای مدیریت پروژه‌های چابک (Agile، Scrum و Kanban).

---

## ✨ تغییرات و ویژگی‌ها

- 🔤 **فونت وزیرمتن (Vazirmatn):** لود خودمیزبان (Self-hosted woff2) بدون نیاز به اینترنت و با سرعت بالا.
- 📐 **راست‌چین استاندارد (RTL First):** اصلاح ساختاری بردهای کانبان (Kanban)، تسک‌بورد، بکلگ اسکرام (Backlog)، ایشوها و منوها.
- 🎨 **تم مدرن سیاپیچا (Siapicha Theme):** تم پیش‌فرض با پالت رنگی مدرن (نیلی و سبز زمردی)، گوشه‌های گرد و داشبورد بازطراحی‌شده.
- 🔢 **ایزوله‌سازی LTR اعداد و شناسه‌ها:** رفع به‌هم‌ریختگی شماره تیکت‌ها (`#123`) و کدهای انگلیسی در متن فارسی (`unicode-bidi: isolate`).
- 🇮🇷 **تکمیل ترجمه فارسی:** رفع کلمات ناقص (مانند «عیت» و «قش») و ترجمه کامل رشته‌های انگلیسی در `locale-fa.json`.
- 📱 **بهبود ریسپانسیو:** چیدمان بهینه‌تر در موبایل و تبلت با `overflow-wrap: anywhere`.

---

## 🚀 راه‌اندازی سریع

```bash
# ۱. نصب وابستگی‌ها
npm install

# ۲. اجرای محیط توسعه (پیش‌فرض: تم سیاپیچا روی پورت 9001)
npm start

# ۳. بیلد نسخه نهایی (Production Deploy)
npx gulp deploy
```

> جهت اجرای تم دلخواه: `npx gulp --theme=siapicha` یا `npx gulp --theme=taiga`

### تنظیمات فرانت‌اند (`conf.json`)

```json
{
    "api": "https://your-taiga-backend/api/v1/",
    "eventsUrl": "wss://your-taiga-backend/events",
    "defaultLanguage": "fa",
    "defaultTheme": "siapicha",
    "themes": ["siapicha", "taiga"],
    "rtlLanguages": ["ar", "fa", "he"]
}
```

---

## Taiga Front (Original Upstream Documentation)

[![Managed with Taiga.io](https://img.shields.io/badge/managed%20with-TAIGA.io-709f14.svg)](https://tree.taiga.io/project/taiga/ "Managed with Taiga.io")
[![Build Status](https://img.shields.io/travis/taigaio/taiga-front.svg)](https://travis-ci.org/taigaio/taiga-front "Build Status")

## Get the compiled version

You can get the compiled version of this code in the
[taiga-front-dist](http://github.com/taigaio/taiga-front-dist) repository

## Documentation

Currently, we have authored three main documentation hubs:

- **[API](https://docs.taiga.io/api.html)**: Our API documentation and reference for developing from Taiga API.
- **[Documentation](https://docs.taiga.io/)**: If you need to install Taiga on your own server, this is the place to find some guides.
- **[Taiga Community](https://community.taiga.io/)**: This page is intended to be the support reference page for the users.

## Bug reports

If you **find a bug** in Taiga you can always report it:

- in [Taiga issues](https://tree.taiga.io/project/taiga/issues). **This is the preferred way**
- in [Github issues](https://github.com/taigaio/taiga-front/issues)
- send us a mail to support@taiga.io if is a bug related to [tree.taiga.io](https://tree.taiga.io)
- send us a mail to security@taiga.io if is a **security bug**.

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

- To run **unit tests**

    ```
    npx gulp
    ```

    ```
    npm test
    ```

#### E2E tests

- To run **e2e tests** you need [taiga-back](https://github.com/taigaio/taiga-back) running and

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
