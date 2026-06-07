<div align="center">

# 🌙 أذكاري — Adhkar App

**تطبيق أذكار إسلامي متكامل | A comprehensive Islamic Adhkar app**

[![Flutter](https://img.shields.io/badge/Flutter-3.44-%2302569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-brightgreen?logo=android)](https://github.com/galxys2s2-cloud/adhkar-app/releases)
[![Web](https://img.shields.io/badge/Web-GitHub%20Pages-%23181717?logo=github)](https://galxys2s2-cloud.github.io/adhkar-app/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

<br>

> **بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ**
>
> *"الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ"*
> — سورة الرعد، الآية 28

<br>

<img src="https://galxys2s2-cloud.github.io/adhkar-app/icons/Icon-192.png" width="120" alt="أذكاري Logo">

</div>

---

## 📱 عن التطبيق — About

**أذكاري** هو تطبيق أذكار إسلامي يعمل **بدون إنترنت (Offline-First)**، يضم مجموعة متكاملة من الأذكار والأدعية المأثورة من **الحصن المسلم**، **صحيح البخاري**، و**صحيح مسلم**، مع واجهة تراثية عربية أنيقة.

Designed as a modern, offline-first adhkar app with a heritage Islamic aesthetic — dark navy & gold theme, Amiri calligraphy, and arabesque decorative elements.

---

## ✨ المميزات — Features

### 🌟 الأذكار
| القسم | المحتوى |
|-------|---------|
| 🌅 **أذكار الصباح** | 30+ ذكرًا من أذكار الصباح الثابتة |
| 🌆 **أذكار المساء** | 30+ ذكرًا من أذكار المساء مع السور القصيرة |
| 🕌 **أذكار بعد الصلاة** | أذكار ما بعد الصلوات الخمس |
| 🛌 **أذكار النوم** | أدعية النوم والاستيقاظ |

### 🤲 الأدعية
- **٢٦ قسمًا** من الأدعية المأثورة (الطعام، السفر، الابتلاء، المطر، رمضان...)
- جميع الأدعية مع النص العربي والتخريج

### 📿 التسبيح
- عداد تسبيح رقمي مع **Auto-Advance** (الانتقال التلقائي للذكر التالي)
- عدّاد لكل ذكر على حدة

### 🎨 التصميم
- واجهة **تراثية عربية** — نيلي غامق + ذهبي + عاجي
- خط **Amiri** العثماني (مضمّن، يعمل offline)
- زخارف **Arabesque** (CustomPainter)
- دعم **Dark Mode**
- خط عربي واضح وكبير للقراءة المريحة

### ⚡ التقنية
- **Offline-First** — لا يحتاج إنترنت بعد التثبيت
- **Flutter 3.44** — Riverpod, GoRouter, Hive
- **Fast & Lightweight** — APK بحجم ~18MB
- **PWA-ready** — تجربة ويب سلسة عبر GitHub Pages

---

## 🖼️ لقطات الشاشة — Screenshots

> *سيتم إضافة لقطات شاشة قريبًا*

---

## 🚀 التحميل — Download

### Android APK

[<img src="https://img.shields.io/badge/📥_تحميل_آخر_إصدار-v1.0.0-brightgreen?style=for-the-badge" alt="Download">](https://github.com/galxys2s2-cloud/adhkar-app/releases/latest)

| Architecture | الحجم | الرابط |
|-------------|-------|--------|
| **arm64-v8a** (معظم الأجهزة الحديثة) | ~18 MB | [⬇️ Download](https://github.com/galxys2s2-cloud/adhkar-app/releases/latest/download/app-arm64-v8a-release.apk) |
| **armeabi-v7a** (الأجهزة القديمة) | ~14 MB | [⬇️ Download](https://github.com/galxys2s2-cloud/adhkar-app/releases/latest/download/app-armeabi-v7a-release.apk) |
| **x86_64** (المحاكيات) | ~18 MB | [⬇️ Download](https://github.com/galxys2s2-cloud/adhkar-app/releases/latest/download/app-x86_64-release.apk) |

### 🌐 Web Version

[<img src="https://img.shields.io/badge/🌐_جرب_النسخة_الويب-FF5722?style=for-the-badge" alt="Web">](https://galxys2s2-cloud.github.io/adhkar-app/)

> افتح الرابط في متصفحك — لا يحتاج تثبيت

---

## 🛠️ التقنيات المستخدمة — Tech Stack

| التقنية | الاستخدام |
|---------|-----------|
| [Flutter 3.44](https://flutter.dev) | إطار العمل الرئيسي |
| [Riverpod](https://riverpod.dev) | إدارة الحالة (State Management) |
| [GoRouter](https://pub.dev/packages/go_router) | التنقل بين الشاشات |
| [Hive](https://pub.dev/packages/hive) | التخزين المحلي (Offline) |
| [Flutter CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) | الزخارف التراثية |
| [Amiri Font](https://www.amirifont.org) | الخط العربي العثماني |
| [GitHub Actions](https://github.com/features/actions) | CI/CD — بناء APK + Web |
| [GitHub Pages](https://pages.github.com) | استضافة النسخة الويب |

---

## 📂 هيكل المشروع — Project Structure

```
lib/
├── core/
│   ├── theme/          # الألوان، الخطوط، الثيم
│   ├── router/         # إعدادات GoRouter
│   └── constants/      # الثوابت العامة
├── data/
│   ├── json/           # ملفات الأذكار والأدعية
│   └── repositories/   # طبقة البيانات
├── features/
│   ├── home/           # الشاشة الرئيسية
│   ├── adhkar/         # الأذكار (صباح، مساء، بعد الصلاة)
│   ├── duaa/           # الأدعية
│   ├── tasbeeh/        # التسبيح
│   └── settings/       # الإعدادات
└── shared/
    └── widgets/        # المكونات المشتركة
```

---

## 🧪 التطوير محليًا — Local Development

```bash
# Clone the repository
git clone https://github.com/galxys2s2-cloud/adhkar-app.git
cd adhkar-app

# Install dependencies
flutter pub get

# Run (Android)
flutter run

# Build APK
flutter build apk --release --split-per-abi

# Build Web
flutter build web --release --base-href /adhkar-app/
```

### متطلبات التشغيل — Requirements

- Flutter SDK 3.27+
- Android SDK (ل build Android)
- أي متصفح حديث (للنسخة الويب)

---

## 🤝 المساهمة — Contributing

نرحب بأي مساهمة! إذا وجدت خطأ في نص أو دعاء، أو عندك اقتراح لتحسين التطبيق:

1. **Open an Issue** — [github.com/galxys2s2-cloud/adhkar-app/issues](https://github.com/galxys2s2-cloud/adhkar-app/issues)
2. **Pull Request** — Fork → Branch → PR

> **ملاحظة:** كل الأدعية والأذكار مأخوذة من مصادر موثوقة (الحصن المسلم، صحيح البخاري، صحيح مسلم). نرجو التأكد من صحة أي إضافة.

---

## 📜 الترخيص — License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**تذكّر:** *"خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ"* — رسول الله ﷺ

<br>

[🌐 Web App](https://galxys2s2-cloud.github.io/adhkar-app/) • [📥 Download APK](https://github.com/galxys2s2-cloud/adhkar-app/releases/latest) • [🐛 Report Issue](https://github.com/galxys2s2-cloud/adhkar-app/issues)

</div>
