# Features Structure

هيكل تنظيم الـ Features في التطبيق

## 📁 Structure Overview

```
lib/features/
├── home/           # الصفحة الرئيسية
├── categories/     # صفحة جميع الفئات
├── analysis/       # صفحة التحليل والإحصائيات
├── auth/           # صفحات التسجيل والدخول
├── splash/         # شاشة البداية
├── onboarding/     # شاشات التعريف بالتطبيق
└── database_test/  # اختبارات قاعدة البيانات
```

## 📄 Files Description

### 🏠 Home Page
**File:** `lib/features/home/home_page.dart`

المكونات:
- Header (مرحبا + اسم المستخدم)
- Progress Bar (نسبة المصروفات)
- Categories Section (3 فئات رئيسية)
- Spending Chart (المصروفات الأسبوعية)

الـ Navigation:
- Show More → CategoriesPage
- See all → AnalysisPage
- Category Card → Dialog (Manual/Voice/Analysis)

---

### 📊 Categories Page
**File:** `lib/features/categories/categories_page.dart`

- عرض جميع الفئات في Grid
- كل فئة لها:
  - Icon
  - Name
  - Total Amount
  - Gradient Color

---

### 📈 Analysis Page
**File:** `lib/features/analysis/analysis_page.dart`

المكونات:
- Total Spending Summary Card
- Weekly Overview (Bar Chart)
- Category Breakdown (Progress Bars)

---

## 🎨 Theme & Colors

**File:** `lib/core/theme/app_colors.dart`

الألوان المستخدمة:
- Background: `#FAFAFA` (أبيض خفيف)
- Primary: `#003566` (أزرق غامق)
- Secondary: `#00CCFF` (أزرق فاتح)
- Chart Bars: `#C5C9D0`, `#003566`
- Chart Background: `#F4F3F3`

### Category Gradients:
- Shopping: تركواز → أزرق غامق
- Bills: أحمر → أزرق غامق
- Health: أخضر → أزرق غامق
- Activities: بنفسجي → أزرق غامق
- Food: أزرق → أزرق غامق
- Education: تركواز فاتح → أزرق غامق
- Entertainment: برتقالي → وردي

---

## 🔄 Navigation Flow

```
HomePage
  ├─→ Show More → CategoriesPage
  ├─→ See all → AnalysisPage
  └─→ Category Card → Dialog
        ├─→ Manual Entry
        ├─→ Voice Recording
        └─→ View Analysis
```

---

## ✨ Features Implemented

✅ Home Page with Categories & Spending Chart
✅ Categories Grid Page
✅ Analysis Page with Charts
✅ Category Dialog (3 Options)
✅ Manual Entry Form
✅ Voice Recording UI
✅ Scanner Options (Camera/Gallery)
✅ Bottom Navigation Bar
✅ Responsive Design

---

## 📝 Notes

- جميع الصفحات تستخدم `AppColors` للألوان
- التصميم responsive ويدعم مقاسات مختلفة
- Navigation باستخدام `MaterialPageRoute`
- الكود منظم ومقسم لـ widgets منفصلة
