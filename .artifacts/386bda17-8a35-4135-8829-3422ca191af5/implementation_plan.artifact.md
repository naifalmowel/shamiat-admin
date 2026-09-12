# خطة تنفيذ مشروع لوحة تحكم مطعم شاميات الموحدة

سيتم إعادة هيكلة الكود بالكامل لاستخدام نمط **MVVM** مع **Provider** لإدارة الحالة، وربطه بـ **Firebase** (للمصادقة وقاعدة البيانات) و **Supabase** (لتخزين الصور).

## تفاصيل الربط السحابي
- **Firebase Auth:** لتسجيل دخول المديرين.
- **Firebase Firestore:** لتخزين بيانات المنتجات، الفئات، والكاروسيل.
- **Supabase Storage:** لرفع وإدارة صور المنتجات والعروض.
- **JSON Seeder:** أداة لرفع محتويات ملف `menu.json` إلى Firestore لمرة واحدة.

## التغييرات المقترحة

### [المكتبات والتبعيات]
#### [MODIFY] [pubspec.yaml](file:///C:/Users/eng.naif/shamiat_admin/pubspec.yaml)
إضافة مكتبات Firebase، Supabase، Provider، Image Picker، و Cached Network Image.

---

### [هيكل البيانات]
#### [NEW] [menu_item.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/models/menu_item.dart)
تعريف نموذج المنتج المتوافق مع ملف JSON.
#### [NEW] [category.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/models/category.dart)
تعريف نموذج الفئات.

---

### [الخدمات (Services)]
#### [NEW] [firebase_service.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/services/firebase_service.dart)
إدارة Firebase Auth و Firestore (CRUD operations).
#### [NEW] [supabase_service.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/services/supabase_service.dart)
إدارة رفع الصور إلى Supabase Storage.
#### [NEW] [data_seeder.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/services/data_seeder.dart)
وظيفة لرفع بيانات `menu.json` إلى Firestore.

---

### [إدارة الحالة (State Management)]
#### [NEW] [admin_provider.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/providers/admin_provider.dart)
الرابط بين الواجهات والخدمات، يدير حالة المنتجات والتحميل.

---

### [واجهة المستخدم (UI)]
#### [MODIFY] [main.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/main.dart)
تجهيز التطبيق للعمل مع Provider وتهيئة Firebase/Supabase.
#### [NEW] [login_screen.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/screens/login_screen.dart)
شاشة تسجيل الدخول مرتبطة بـ Firebase.
#### [NEW] [dashboard_screen.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/screens/dashboard_screen.dart)
الشاشة الرئيسية المتجاوبة.
#### [NEW] [products_tab.dart](file:///C:/Users/eng.naif/shamiat_admin/lib/screens/tabs/products_tab.dart)
إدارة المنتجات (إضافة، تعديل، حذف، رفع صور).

---

## خطة التحقق
- تشغيل التطبيق والتأكد من نجاح عملية تهيئة Firebase.
- استخدام ميزة Seeder لرفع الـ 100+ منتج من JSON.
- تجربة رفع صورة لمنتج والتأكد من ظهور رابطها من Supabase في Firestore.
- اختبار تسجيل الدخول بصلاحيات المدير.

> [!IMPORTANT]
> سأترك فراغات لمفاتيح API في كود التهيئة لتقوم بتعبئتها.
