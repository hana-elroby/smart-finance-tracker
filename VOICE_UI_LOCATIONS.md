# مواقع الـ Voice Input في الـ UI
## Voice Input UI Locations

## 🎯 **الأماكن الرئيسية للـ Voice Input:**

### 1. **الصفحة الرئيسية (Home Page)**
**المكان:** `lib/widgets/main_layout.dart`

```
📱 الشاشة الرئيسية
├── Navigation Bar (أسفل الشاشة)
├── Plus Button (+) في المنتصف
└── عند الضغط على Plus → يظهر خيارين:
    ├── 🔍 Scan (يسار)
    └── 🎤 Voice (يمين) ← هنا الـ Voice Input
```

**كيفية الوصول:**
1. افتح التطبيق
2. اضغط على الـ Plus Button (+) في وسط الـ Navigation Bar
3. اضغط على أيقونة الـ Microphone (🎤) على اليمين

---

### 2. **صفحة العناصر (Items Page)**
**المكان:** `lib/features/items/items_page.dart`

```
📱 صفحة العناصر
├── قائمة العناصر
├── FAB (Floating Action Button) أسفل يمين
└── عند الضغط على FAB → يظهر خيارين:
    ├── ✏️ Manual Entry
    └── 🎤 Voice Input ← هنا الـ Voice Input
```

**كيفية الوصول:**
1. اذهب لصفحة Items
2. اضغط على الـ FAB (الزر الدائري أسفل يمين)
3. اضغط على أيقونة الـ Microphone (🎤)

---

### 3. **صفحة الفئات (Categories Page)**
**المكان:** `lib/features/categories/categories_page.dart`

```
📱 صفحة الفئات
├── قائمة الفئات
├── عند الضغط على أي فئة
└── يظهر Add Options Bottom Sheet:
    ├── 📝 Manual
    ├── 🎤 Voice ← هنا الـ Voice Input
    └── 📷 Scan
```

**كيفية الوصول:**
1. اذهب لصفحة Categories
2. اضغط على أي فئة (مثل Food, Shopping, إلخ)
3. اضغط على Voice من الخيارات

---

## 🎨 **شكل الـ Voice Input UI:**

### **الـ Floating Options (في الصفحة الرئيسية):**
```
        🔍          🎤
    [Scan]      [Voice]
         \      /
          \    /
           [+]
    ________________
    [🏠] [🎁] [📄] [👤]
```

### **الـ Voice Input Dialog:**
```
┌─────────────────────────┐
│    🎤 Voice Input       │
├─────────────────────────┤
│                         │
│   🔵 Recording...       │
│   ~~~~~~~~~~~~~~~~~~~   │
│   Sound waves animation │
│                         │
├─────────────────────────┤
│ [Text input field]      │
├─────────────────────────┤
│ [Reset] [Add Transaction]│
└─────────────────────────┘
```

---

## 🔧 **الكود المسؤول عن كل مكان:**

### 1. **Main Layout (الصفحة الرئيسية):**
```dart
// lib/widgets/main_layout.dart - line ~140
GestureDetector(
  onTap: () {
    HapticFeedback.lightImpact();
    setState(() => _showFloatingOptions = false);
    _showVoiceInput(); // ← هنا يفتح الـ Voice Dialog
  },
  child: Container(
    // Voice button styling
    child: Icon(Icons.mic_rounded),
  ),
)

// الدالة اللي بتفتح الـ Voice Dialog
void _showVoiceInput() async {
  final result = await showSimpleVoiceInputDialog(context);
  // Handle result...
}
```

### 2. **Items Page:**
```dart
// lib/features/items/items_page.dart - line ~220
onTap: () async {
  HapticFeedback.lightImpact();
  setState(() => _showFloatingOptions = false);
  final result = await showSimpleVoiceInputDialog(context);
  // Handle result...
}
```

### 3. **Categories Page:**
```dart
// lib/features/categories/categories_page.dart
showAddOptionsBottomSheet(
  context,
  categoryName: category.name,
  onVoiceTap: () => showSimpleVoiceInputDialog(context),
  // Other options...
);
```

---

## 🎯 **الخلاصة:**

**الـ Voice Input موجود في 3 أماكن رئيسية:**

1. **🏠 الصفحة الرئيسية:** Plus Button → Voice (يمين)
2. **📦 صفحة العناصر:** FAB → Voice
3. **📂 صفحة الفئات:** اختر فئة → Voice

**كلهم يفتحوا نفس الـ Dialog:** `showSimpleVoiceInputDialog(context)`